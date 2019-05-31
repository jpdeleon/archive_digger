from urllib.request import urlopen, urlretrieve
from os.path import exists, isdir, join
from os import makedirs
import sys
import argparse

import pandas as pd
from tqdm import tqdm
from astropy import units as u
from astropy.coordinates import SkyCoord
from astropy.coordinates import match_coordinates_3d
from astropy.io import ascii

BASE = 'http://www.mpia.de/homes/trifonov/'
URL = BASE+'HARPS_RVBank.html'
ALL_DATA_PRODUCTS = ['Data product plots', 'Pre-upgrade DRS', 'Post-upgrade DRS',
                     'Pre-upgrade standard SERVAL', 'Post-upgrade standard SERVAL',
                     'Pre-upgrade mlc SERVAL (use these)',
                     'Post-upgrade mlc SERVAL(use these)']
         
parser = argparse.ArgumentParser(description="""
                parse RV data from {}""".format(URL),
                usage='use "%(prog)s --help" for more information',
                formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('-ra', help='R.A. [deg]', type=float, default=None)
parser.add_argument('-dec', help='Dec. [deg]', type=float, default=None)
parser.add_argument('-p', '--pipeline', help='pipeline', 
                    choices=ALL_DATA_PRODUCTS, default='Pre-upgrade DRS')
parser.add_argument('-c', '--clobber', help='clobber database (default=False)',
    action='store_true', default=False)
parser.add_argument('-o', '--outdir', help='output directory', default=None)
parser.add_argument('-s', '--save', help='save figure (default=False)',
    action='store_true', default=False)
parser.add_argument('-v', '--verbose', help='verbose (default=False)',
    action='store_true', default=False)
parser.add_argument('-a', '--save_all', help='save all available data (default=False)',
    action='store_true', default=False)

args = parser.parse_args()
ra   = args.ra
dec  = args.dec
col  = args.pipeline
outdir = args.outdir
save = args.save
verbose = args.verbose
clobber = args.clobber
save_all = args.save_all

def get_harps_database(dirloc='.',clobber=clobber):
    '''
    '''
    fp = join(dirloc,'harps_db.csv')
    
    if not exists(fp) or clobber:    
        #scrape html table
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
        
    return df

def query_target(target, df, dist=1, unit=u.arcsec, verbose=verbose):
    '''
    '''
    if verbose:
        print('querying (ra={}, dec={})...\n'.format(target.ra,target.dec))
    coords = SkyCoord(ra=df['RA_deg'], dec=df['DEC_deg'], unit=u.deg)
    idx, sep2d, dist3d = match_coordinates_3d(target, catalogcoord=coords, nthneighbor=1)
    #search distance
    dist = dist*unit
    
    if dist3d*unit < dist:
        res = df.iloc[[idx]]
        if verbose:
            print('Available data products: {}\n'.format(df.iloc[[idx]][df.columns[7:14]].T))
        return res
    
    else:
        nearest_obj = df.iloc[[idx]]['Target']
        print('Nearest HARPS obj to target is {} (d={}\')\n'.format(nearest_obj,dist3d))
        return None

def get_rv(res, col=col, return_fp=True):
    msg = '{} is not available in list of data products\n'.format(col)
    assert col in ALL_DATA_PRODUCTS, msg
    
    if col=='Data product plots':
        return NotImplementedError
    else:
        folder = res['Target'].values[0]+'_RVs'
        filename = res[col].values[0]
#         assert filename.split('.')[-1]=='vels'
        url = join(BASE,folder,filename)
        rv = ascii.read(url).to_pandas()
    #     rv.columns = 'BJD RV RV_err'.split()
        if return_fp:
            return rv,filename
        else:
            return rv

def get_plot(res, outdir=outdir, verbose=verbose):
    '''
    '''
    if outdir is None:
        outdir = res['Target'].values[0]
        
    folder = outdir+'_RVs'
    filename = res['Data product plots'].values[0]   
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

if __name__=='__main__':
    if (ra is None) and (dec is None):
        #test
        print('===TEST RUN===\n')
        ra=289
        dec=5.2921
    target_coord = SkyCoord(ra=ra, dec=dec, unit=u.deg)
        
    df = get_harps_database(dirloc='.', clobber=False)
    res = query_target(target_coord, df, dist=1, unit=u.arcsec, verbose=verbose)
    
    if res is not None:
        # get data
        if outdir is None:
            outdir = res['Target'].values[0]
        if not exists(outdir):
            makedirs(outdir)
        
        if save_all:
            for p in tqdm(ALL_DATA_PRODUCTS):
                if str(res[p].values[0])!='nan':
                    if p=='Data product plots':
                        fp = get_plot(res, outdir=outdir, verbose=verbose)
                        fp = join(outdir,fp)
                    else:
                        rv, fp = get_rv(res, col=p, return_fp=True)
                        fp = join(outdir,fp)
                        rv.to_csv(fp,index=False)
                    if verbose:
                        print('Saved: {}'.format(fp)) 
        else:
            if str(res[col].values[0])!='nan':
                rv, fp = get_rv(res, col, return_fp=True)
                if save:
                    rv.to_csv(fp,index=False)
                    if verbose:
                        print('Saved: {}'.format(fp))   
                else:
                    #just print
                    print('{}:\n{}'.format(col,rv))