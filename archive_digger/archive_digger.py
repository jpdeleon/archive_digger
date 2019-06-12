#!/usr/bin/env python

from urllib.request import urlopen, urlretrieve
from os.path import exists, isdir, join
from collections import OrderedDict
from os import makedirs
from glob import glob
# import logging
# from imp import reload
import sys
import argparse

import numpy as np
import pandas as pd
import matplotlib.pyplot as pl
import matplotlib.cm as cm
from tqdm import tqdm
import astropy.units as u
from astropy.coordinates import SkyCoord
from astropy.wcs import WCS
from astroquery.mast import Catalogs
from astropy.coordinates import match_coordinates_3d
from astropy.visualization.wcsaxes import SphericalCircle
from astropy.io import ascii
from astroplan.plots import plot_finder_image
pd.set_option('precision', 6)

ADS_TOKEN      = 'SES6KoDxfTO7jBNmOAmfd5eGRfSbzDr6e1UcyChS'
BASE = 'http://www.mpia.de/homes/trifonov/'
URL = BASE+'HARPS_RVBank.html'
ALL_DATA_PRODUCTS = ['Data product plots', 'Pre-upgrade DRS', 'Post-upgrade DRS',
                     'Pre-upgrade standard SERVAL', 'Post-upgrade standard SERVAL',
                     'Pre-upgrade mlc SERVAL (use these)',
                     'Post-upgrade mlc SERVAL(use these)']

# LOG_FILENAME   = join(outdir,'query_harps.log')
# reload(logging)
# logging.basicConfig(filename=LOG_FILENAME ,level=logging.DEBUG)

def get_harps_database(dirloc='../data',verbose=True,clobber=False):
    """Download/load harps database as a csv file.

    Parameters
    ----------
    dirloc : str
        directory location to save csv table
    verbose : bool
        print texts
    clobber : bool
        download file, else load previously downloaded file

    Returns
    -------
    df : pandas.DataFrame
        database dataframe
    """
    fp = join(dirloc,'harps_db.csv')

    if not exists(fp) or clobber:
        #scrape html table
        if verbose:
            print('Downloading {}\n'.format(URL))
        table = pd.read_html(URL, header=0)
        #choose first table
        df = table[0]

        #coordinates
        coords = SkyCoord(ra=df['RA'], dec=df['DEC'], unit=(u.hourangle,u.deg))
        df['RA_deg'] = coords.ra.deg
        df['DEC_deg'] = coords.dec.deg

        #save table as csv
        if not isdir(dirloc):
            makedirs(dirloc)
        df.to_csv(fp,index=False)
        print('Saved: {}'.format(fp))
    else:
        #load table if file already exists
        df = pd.read_csv(fp)
        print('Loaded: {}'.format(fp))
    return df

def query_target(target_coord, df, dist=1*u.arcsec, verbose=True):
    """Cross-match target coordinates to HARPS database.

    Parameters
    ----------
    targ_coord : astropy.coordinates.SkyCoord
        targ_coord
    df : pandas.DataFrame
        dataframe/ table of HARPS data downloaded previously
    dist : astropy.units
        angular distance within which to find nearest HARPS object
    verbose : bool
        print texts

    Returns
    -------
    res : pandas.DataFrame
        resulting masked dataframe
    """
    if verbose:
        print('\nQuerying objects within {} of ra,dec=({},{})\n'.format(dist,
                target_coord.ra.value,target_coord.dec.value))
    coords = SkyCoord(ra=df['RA_deg'], dec=df['DEC_deg'], unit=u.deg)

    #compute angular separation between target and all HARPS objects and
    #check which falls within `dist`
    idxs = target_coord.separation(coords)<dist

    #check if there is any within search space
    if idxs.sum() > 0:
        #result may be multiple objects
        res = df[idxs]

        if verbose:
            msg='There are {} matches: {}'.format(len(res), res['Target'].values)
            print(msg)
#             logging.info(msg)
            print('{}\n\n'.format(df.loc[idxs,df.columns[7:14]].T))
        return res

    else:
        #find the nearest HARPS object in the database to target
        idx, sep2d, dist3d = match_coordinates_3d(target_coord, coords, nthneighbor=1)
        nearest_obj = df.iloc[[idx]]['Target'].values[0]
        ra,dec = df.iloc[[idx]][['RA_deg','DEC_deg']].values[0]
        msg='Nearest HARPS obj to target is\n{}: ra,dec=({:.4f},{:.4f})\n'.format(nearest_obj,ra,dec)
        print(msg)
#         logging.info(msg)
        print('Try angular distance larger than d={:.4f}\"\n'.format(sep2d.arcsec[0]))
        return None

def get_rv(res, col, outdir=None, return_fp=True):
    """Download rv (*.vels) files from HARPS database

    Parameters
    ----------
    res : pandas.DataFrame
        masked dataframe from query_target
    outdir : str
        download directory location
    return_fp : bool
        return file path

    Returns
    -------
    rv, fp : pandas.DataFrame, str
        downloaded rv, file path
    """
    msg = '{} is not available in list of data products\n'.format(col)
    assert col in ALL_DATA_PRODUCTS, msg
    assert isinstance(res,pd.Series)

    targetname = res['Target']
    if outdir is None:
        outdir = targetname
    else:
        #save with folder name==ticid
        if res['ticid'] is not None:
            outdir = join(outdir,'tic'+str(res['ticid']))
#         elif res['toi'] is not None:
#             outdir = join(outdir,str(res['toi']).split('.')[0])
        else:
            outdir = join(outdir,targetname)
    if not isdir(outdir):
        makedirs(outdir)

    if col=='Data product plots':
        return NotImplementedError
    else:
        folder = res['Target']+'_RVs'
        filename = res[col]
        assert filename.split('.')[-1]=='vels'
        url = join(BASE,folder,filename)
        fp = join(outdir,'tic'+str(res['ticid'])+'_'+filename)
        rv = ascii.read(url).to_pandas()
#         rv.columns = 'BJD RV RV_err'.split()
        if return_fp:
            return rv,fp
        else:
            return rv

def get_plot(res, outdir=None, verbose=True):
    """Download quick look RV plots (*.pdf) from database

    Parameters
    ----------
    res : pandas.DataFrame
        resulting masked dataframe from `query_target`
    outdir : str
        directory location
    verbose : bool
        print texts

    Returns
    -------
    fp : str
        file path
    """
    assert isinstance(res,pd.Series)

    targetname = res['Target']
    tic = res['ticid']
    if outdir is None:
        outdir = targetname
    else:
        #save with folder name==ticid
        if tic is not None:
            outdir = join(outdir,'tic'+str(tic))
#         elif res['toi'] is not None:
#             outdir = join(outdir,str(res['toi']).split('.')[0])
        else:
            outdir = join(outdir,targetname)
    if not isdir(outdir):
        makedirs(outdir)

    folder = targetname+'_RVs'
    filename = res['Data product plots']
    assert filename.split('.')[-1]=='pdf'
    url = join(BASE,folder,filename)
    fp = join(outdir,'tic'+str(tic)+'_'+filename)
    #save
    try:
        urlretrieve(url, fp)
        print('Saved: {}\n'.format(fp))
    except Exception as e:
        print('Error: {}\nNot saved: {}\n'.format(e,url))
    return fp

def download_product(res, col, outdir=None, save_csv=False, verbose=True):
    """Download specified data product from HARPS database.

    Parameters
    ----------
    res : pandas.DataFrame
        masked dataframe from `query_target`
    col : str
        column name corresponding to a data product
    outdir : str
        download directory location
    save_csv : bool
        save .vels as csv file
    verbose : bool
        print texts
    """
    targetnames = []
    targetnames.append(res['Target'])

    if 'ticid' in res.index.tolist():
        if res['ticid'] is not None:
            targetnames.append('tic'+str(res['ticid']))
    if 'toi' in res.index.tolist():
        if res['toi'] is not None:
            targetnames.append('toi'+str(res['toi']))
    targetnames.append('\n')

    if str(res[col])!='nan':
        if col=='Data product plots':
            fp = get_plot(res, outdir=outdir, verbose=verbose)
        else:
            rv, fp = get_rv(res, col, outdir=outdir, return_fp=True)
            if save_csv:
                f = open(fp, 'w')
                #add known star names on the first line
                f.write('#'+', '.join(targetnames))
                #no column names
                rv.to_csv(f,index=False,header=False,mode='a') #append
                f.close()
                if verbose:
                    print('Saved: {}'.format(fp))
            else:
                if verbose:
                    #just print
                    print('{}:\n{}\n\n'.format(col,rv))

def get_tois(clobber=True, outdir='../data', verbose=False):
    """Download TOI list from TESS Alert/TOI Release.

    Parameters
    ----------
    clobber : bool
        re-download table and save as csv file
    outdir : str
        download directory location
    verbose : bool
        print texts

    Returns
    -------
    d : pandas.DataFrame
        TOI table as dataframe
    """
    dl_link = 'https://exofop.ipac.caltech.edu/tess/download_toi.php?sort=toi&output=csv'
    fp = join(outdir,'TOIs.csv')
    if not exists(outdir):
        makedirs(outdir)

    if not exists(fp) or clobber:
        d = pd.read_csv(dl_link)#, dtype={'RA': float, 'Dec': float})
        d.to_csv(fp, index=False)
        print('Saved: {}'.format(fp))
    else:
        d = pd.read_csv(fp)
        print('Loaded: {}'.format(fp))
    return d

def query_toi(toi=None, tic=None, clobber=True, outdir='../data', verbose=False):
    """Find TOI or TIC from the full TOI Release table from `get_tois`.

    Parameters
    ----------
    toi : float
        toi number
    tic : int
        TIC ID
    clobber : bool
        re-download table and save as csv file
    outdir : str
        download directory location
    verbose : bool
        print texts

    Returns
    -------
    d : pandas.DataFrame
        TOI table as dataframe
    """
    d = get_tois(clobber=clobber, outdir=outdir, verbose=verbose)
    assert np.any([tic,toi]), 'Supply toi or tic'
    #TOI csv file from TESS alerts

    if tic:
        q=d[d['TIC ID']==tic]
    else:
        if isinstance(toi, int):
            toi = float(str(toi)+'.01')
        else:
            planet = str(toi).split('.')[1]
            assert len(planet)==2, 'use pattern: TOI.01'
        q = d[d['TOI']==toi]
        if verbose:
            tic = q['TIC ID'].values[0]
            per = q['Period (days)'].values[0]
            t0  = q['Epoch (BJD)'].values[0]
            t14 = q['Duration (hours)'].values[0]
            dep = q['Depth (ppm)'].values[0]
            comments=q[['TOI','Comments']].values
            print('TIC ID\t{}\nP(d)\t{}\nT0(BJD)\t{}\nT14(hr)\t{}\ndepth(ppm)\t{}\n'.format(tic,per,t0,t14,dep))
            print('Comment:\n{}\n'.format(comments))
    return q.sort_values('TOI')

def save_tics(outdir='.'):
    """Save TIC IDs.

    Parameters
    ----------
    outdir : str
        download directory location

    Returns
    -------
    None
    """
    d = get_tois()
    tics = d['TIC ID'].values

    fp = join(outdir,'tics_from_alerts.txt')
    np.savetxt(fp,tics,fmt='%d')
    print('Saved: {}'.format(fp))
    return None

def plot_fov(target_coord,res,fov_rad=60*u.arcsec,ang_dist=15*u.arcsec,
             survey='DSS',verbose=True,outdir=None,savefig=False):
    """Plot FOV indicating the query position (magenta reticle) and nearby HARPS
    target (colored triangle), query radius (green circle) and Gaia DR2 sources
    (red squares)

    Parameters
    ----------
    targ_coord : astropy.coordinates.SkyCoord
        targ_coord
    res : pandas.DataFrame
        masked dataframe from `query_target`
    fov_rad : astropy.unit
        field of view radius
    ang_dist : astropy.unit
        angular distance within which to find nearest HARPS object
    survey : str
        survey name of archival image
    outdir : str
        download directory location
    verbose : bool
        print texts
    savefig : bool
        save figure

    Returns
    -------
    res : pandas.DataFrame
        masked dataframe
    """
    if verbose:
        print('\nGenerating FOV ...\n')

    nearest_obj = res['Target'].values[0]
    tic = res['ticid'].values[0]
    if outdir is None:
        outdir = nearest_obj
    else:
        #save with folder name==ticid
        if len(res['ticid'].dropna())>0:
            outdir = join(outdir,'tic'+str(tic))
#         elif res['toi'] is not None:
#             outdir = join(outdir,str(res['toi']).split('.')[0])
        else:
            outdir = join(outdir,nearest_obj)
    if not isdir(outdir):
        makedirs(outdir)

    nearest_obj_ra,nearest_obj_dec =res[['RA_deg','DEC_deg']].values[0]
    nearest_obj_coord = SkyCoord(ra=nearest_obj_ra, dec=nearest_obj_dec, unit=u.deg)

    #indicate target location with magenta reticle
    ax,hdu=plot_finder_image(target_coord,fov_radius=fov_rad,reticle=True,
        survey=survey,reticle_style_kwargs={'label':'target'})
    c = SphericalCircle((nearest_obj_ra, nearest_obj_dec)*u.deg, ang_dist,
        edgecolor='C2', transform=ax.get_transform('icrs'),
        facecolor='none', label='query radius')
    ax.set_title('{} ({})'.format(survey,nearest_obj))
    ax.add_patch(c)

    #harps objects within angular distance
    coords = SkyCoord(ra=res['RA_deg'], dec=res['DEC_deg'], unit=u.deg)
    sep2d = target_coord.separation(coords)

    #get indices that satisfy the criterion
    idxs = sep2d < ang_dist
    colors = cm.rainbow(np.linspace(0, 1, idxs.sum()))

    if len(coords[idxs])>1:
        #plot each star match within search radius
        for n,(coord,color) in enumerate(zip(coords[idxs],colors)):
            ax.scatter(coord.ra.deg, coord.dec.deg, transform=ax.get_transform('icrs'), s=300,
               marker='^', edgecolor=color, facecolor='none',label=res.loc[idxs,'Target'].values[n])
    else:
        ax.scatter(coords.ra.deg, coords.dec.deg, transform=ax.get_transform('icrs'), s=300,
               marker='^', edgecolor='blue', facecolor='none',label=res['Target'].values[0])

    #gaia dr2 sources
    wcs = WCS(hdu.header)
    mx, my = hdu.data.shape

    #query gaia sources within region centered at target_coord
    gaia_sources = Catalogs.query_region(target_coord, radius=fov_rad,
                                         catalog="Gaia", version=2).to_pandas()
    for r,d in gaia_sources[['ra','dec']].values:
        pix = wcs.all_world2pix(np.c_[r,d],1)[0]
        ax.scatter(pix[0], pix[1], marker='s', s=50, edgecolor='C1',
            facecolor='none', label='gaia source')
    pl.setp(ax, xlim=(0,mx), ylim=(0,my))

    #remove redundant labels due to 4 reticles
    handles, labels = pl.gca().get_legend_handles_labels()
    by_label = OrderedDict(zip(labels, handles))
    pl.legend(by_label.values(), by_label.keys())
    if savefig:
        fp = join(outdir,'tic{}_{}_fov.png'.format(tic,nearest_obj))
        ax.figure.savefig(fp,bbox_inches='tight')
        print('Saved: {}'.format(fp))
    return None

def summarize_match_table(tics=None,outdir='../all_tois/',save_csv=True,verbose=True):
    """Given TIC IDs, a table TOI parameters from TESS releases is returned
    If tics is None, tic ids are inferred from directories created inside outdir

    Parameters
    ----------
    tics : list
        TIC IDs of downloaded files; infer tic from directory name if None
    outdir : str
        directory location of downloaded files from HARPS database
    save_csv : bool
        save cross-matched TOI table as csv
    verbose : bool
        print texts

    Returns
    -------
    c1 = pandas.DataFrame
        masked TOI table
    """
    #selected columns
    cols = ['TESS Mag','TOI','Depth (mmag)','Planet Radius (R_Earth)',
    'Period (days)','Stellar Radius (R_Sun)','Stellar Eff Temp (K)', 'Comments']

    if tics is None:
        #get TIC from directory names of downloaded files
        fl = glob(join(outdir,'tic*'))
        tics = []
        for f in fl:
            tics.append(f.split('/')[-1][3:])
        if verbose:
            print('matched TOIs/TICs: {}\n'.format(len(tics)))
    #count number of spectra
    nspectra={}
    names={}
    for tic in tics:
        fl = glob(join(outdir,'tic'+tic,'*.vels'))
        num=[]
        if len(fl)>1:
            for f in fl:
                d=pd.read_csv(f)
                num.append(len(d))
            nspectra[int(tic)]=max(num)
        else:
            d=pd.read_csv(fl[0])
            nspectra[int(tic)]=len(d)
        #get names from header; remove #
        names[int(tic)]=d.columns[0][1:]
    df=pd.DataFrame(data=[nspectra,names]).T
    df.columns = ['nspectra','HARPS_name']
    #download recent TOI table
    tois = get_tois(verbose=False)
    idxs = []
    for tic in tqdm(tics):
        q = tois[tois['TIC ID']==int(tic)]
        idxs.append(q.index[0])

    # observed tois
    o = tois.loc[idxs]
    o = o.set_index('TIC ID')
    final = pd.merge(o, df, left_index=True, right_index=True, how='inner')
    #all_cols = final.columns.tolist()
    final.index.name = 'TIC'

    # chosen params
    cols.append('nspectra')
    cols.append('HARPS_name')

    c1 = final.sort_values('TESS Mag',ascending=True)
    c2 = final.sort_values('TOI',ascending=True)
    if save_csv:
        fp1 = join(outdir,'TOI_with_harps_data.csv')
        fp2 = join(outdir,'TOI_with_harps_data_selected_cols.txt')
        c1.to_csv(fp1,index=True)
        c2[cols].to_csv(fp2,index=True)
        print('Saved: {}'.format(fp1))
        print('Saved: {}'.format(fp2))
    return c1

def search_ads(results_dir=None,verbose=False):
    """Search NASA ADS for publication mentioning the TOI.

    Parameters
    ----------
    results_dir : str
        directory location of downloaded files
    verbose : bool
        print texts

    Returns
    -------
    toi_pub : dict
        dictionary with TIC as key and paper tile as value
    """
    try:
        import ads
        ads.config.token = ADS_TOKEN
    except ImportError:
        raise ImportError('please install ads first')

    if results_dir is None:
        results_dir = '.'
    if not exists(results_dir):
        sys.exit('{} does not exist!'.format(results_dir))
    tics = glob(join(results_dir,'tic*'))

    toi_pub = {}
    if len(tics)>0:
        for tic in tqdm(tics):
            #TOI.01
            tic = tic.split('/')[-1][3:]
            q = query_toi(tic=int(tic),clobber=False)
            toi = q['TOI'].values[0]
            toi = str(toi).split('.')[0]
            #FIXME: filter by year > 2018
            papers = ads.SearchQuery(q='TOI '+(toi), sort="citation_count", fq='database:astronomy')
            toi_pub[tic] = [paper.title for paper in papers]
    else:
        sys.exit('No tic* directories found in {}'.format(results_dir))
    if verbose:
        print(toi_pub)
    return  toi_pub
