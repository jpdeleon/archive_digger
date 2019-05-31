#!/usr/bin/env python

from urllib.request import urlopen, urlretrieve
from os.path import exists, isdir, join
from os import makedirs
# import logging
# from imp import reload
import sys
import argparse

import numpy as np
import pandas as pd
import matplotlib.pyplot as pl
from tqdm import tqdm
import astropy.units as u
from astropy.coordinates import SkyCoord
from astropy.coordinates import match_coordinates_3d
from astropy.io import ascii
from astroplan.plots import plot_finder_image

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
    '''
    '''
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

        #save
        if not isdir(dirloc):
            makedirs(dirloc)
        df.to_csv(fp,index=False)
        print('Saved: {}'.format(fp))
    else:
        df = pd.read_csv(fp)
        print('Loaded: {}'.format(fp))
    return df

def query_target(target, df, dist=1, unit=u.arcsec, verbose=True):
    '''
    '''
    if verbose:
        print('\nQuerying objects within {}\" of ra,dec=({},{})\n'.format(dist,target.ra.value,target.dec.value))
    coords = SkyCoord(ra=df['RA_deg'], dec=df['DEC_deg'], unit=u.deg)
    
    idxs = target.separation(coords)<dist*unit
            
    #search distance
    if idxs.sum() > 0:
        res = df[idxs]
        
        if verbose:
            msg='There are {} matches: {}'.format(len(res), res['Target'].values)
            print(msg)
#             logging.info(msg)        
            print(df.loc[idxs,df.columns[7:14]].T)
        return res
    
    else:
        idx, sep2d, dist3d = match_coordinates_3d(target, coords, nthneighbor=1)
        nearest_obj = df.iloc[[idx]]['Target'].values[0]
        ra,dec = df.iloc[[idx]][['RA_deg','DEC_deg']].values[0]
        msg='Nearest HARPS obj to target is\n{}: ra,dec=({:.4f},{:.4f})\n'.format(nearest_obj,ra,dec)
        print(msg)
#         logging.info(msg)
        print('Try larger angular distance than d={:.4f}\"\n'.format(sep2d.arcsec[0]))
        return None

def get_rv(res, col, outdir=None, return_fp=True):
    '''
    '''
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
        fp = join(outdir,filename)
        rv = ascii.read(url).to_pandas()
#         rv.columns = 'BJD RV RV_err'.split()
        if return_fp:
            return rv,fp
        else:
            return rv

def get_plot(res, outdir=None, verbose=True):
    '''
    save the pdf file
    '''
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
            
    folder = targetname+'_RVs'
    filename = res['Data product plots'] 
    assert filename.split('.')[-1]=='pdf'
    url = join(BASE,folder,filename)
    fp = join(outdir,filename)
    #save
    try:
        urlretrieve(url, fp)
        print('Saved: {}\n'.format(fp))
    except Exception as e:
        print('Error: {}\nNot saved: {}\n'.format(e,url))
    return fp

def download_product(res, col, outdir=None, save_csv=False, verbose=True):
    '''
    '''
    targetnames = []
    targetnames.append(res['Target'])
    if res['ticid'] is not None:
        targetnames.append('tic'+str(res['ticid']))
    if res['toi'] is not None:
        targetnames.append('toi'+str(res['toi']))
    targetnames.append('\n')
    
    if str(res[col])!='nan':
        if col=='Data product plots':
            fp = get_plot(res, outdir=outdir, verbose=verbose)
        else:
            rv, fp = get_rv(res, col, outdir=outdir, return_fp=True)
            if save_csv:
                f = open(fp, 'a')
                #add known star names on the first line
                f.write('#'+', '.join(targetnames))
                #no column names
                rv.to_csv(f,index=False,header=False) 
                f.close()
                if verbose:
                    print('Saved: {}'.format(fp)) 
            else:
                if verbose:
                    #just print
                    print('{}:\n{}'.format(col,rv))
    
def get_tois(clobber=True, outdir='../data', verbose=False):
    '''
    '''
    dl_link = 'https://exofop.ipac.caltech.edu/tess/download_toi.php?sort=toi&output=csv'
    fp = join(outdir,'TOIs.csv')
    if not exists(outdir):
        makedirs(outdir)
    
    if not exists(fp) or clobber:
        d = pd.read_csv(dl_link)
        d.to_csv(fp, index=False)
        print('Saved: {}'.format(fp))
    else:
        d = pd.read_csv(fp)
        print('Loaded: {}'.format(fp))
    return d
    
def query_toi(toi=None, tic=None, clobber=True, outdir='../data', verbose=False):
    '''
    '''
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
    return q.sort_values(by='TOI')

def save_tics(outdir='.'):
    '''
    '''
    d = get_tois()
    tics = d['TIC ID'].values
    
    fp = join(outdir,'tics_from_alerts.txt')
    np.savetxt(fp,tics,fmt='%d')
    print('Saved: {}'.format(fp))
    return None

def plot_fov(target_coord,res,ang_dist=10,verbose=True,outdir='',savefig=False):
    '''
    FIXME: wcs projection
    '''    
    if verbose:
        print('\nGenerating FOV ...\n')
    nearest_obj = res['Target']
    obj_ra,obj_dec =res[['RA_deg','DEC_deg']].values
    sep2d = target_coord.separation(SkyCoord(ra=obj_ra, dec=obj_dec, unit=u.deg))
    rad = ang_dist*u.arcsec
    
    fig, axs = pl.subplots(1,2,figsize=(10,5))
    ax1,hdu=plot_finder_image(target_coord,fov_radius=rad,survey='DSS2 Blue',reticle=True,ax=axs[0])
    ax2,hdu=plot_finder_image(target_coord,fov_radius=rad,survey='DSS2 Red',reticle=True,ax=axs[0])
    
    if sep2d<rad:
        axs[0].scatter(obj_ra, obj_dec, transform=ax1.get_transform(), s=300,
                   edgecolor='red', facecolor='none')
        axs[1].scatter(obj_ra, obj_dec, transform=ax2.get_transform(), s=300,
                   edgecolor='red', facecolor='none')
    if savefig:
        fp = join(outdir,'{}_fov.png'.format(nearest_obj))
        fig.savefig(fp,bbox_inches=False)
        print('Saved: {}'.format(fp))