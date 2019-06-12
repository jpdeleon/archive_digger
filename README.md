# archive_digger
simple query for archival radial velocity data of TESS targets

[![Documentation Status](https://readthedocs.org/projects/archive-digger/badge/?version=latest)](https://archive-digger.readthedocs.io/en/latest/?badge=latest)
[![license](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/dfm/emcee/blob/master/LICENSE)

## Usage
* ./query_harps -h
```
parse RV data from http://www.mpia.de/homes/trifonov/HARPS_RVBank.html

optional arguments:
  -h, --help            show this help message and exit
  -ra RA                R.A. [deg]
  -dec DEC              Dec. [deg]
  -p {0,1,2,3,4,5,6}, --pipeline {0,1,2,3,4,5,6}
                        RV pipeline:
                        [['0' 'Data product plots']
                         ['1' 'Pre-upgrade DRS']
                         ['2' 'Post-upgrade DRS']
                         ['3' 'Pre-upgrade standard SERVAL']
                         ['4' 'Post-upgrade standard SERVAL']
                         ['5' 'Pre-upgrade mlc SERVAL (use these)']
                         ['6' 'Post-upgrade mlc SERVAL(use these)']]
  -d DISTANCE, --distance DISTANCE
                        distance criterion [arcsec]
  -c, --clobber         clobber database (default=False)
  -o OUTDIR, --outdir OUTDIR
                        output directory
  -s SURVEY, --survey SURVEY
                        imaging survey (see https://astroquery.readthedocs.io/en/latest/skyview/skyview.html)
  -toi TOI              toi
  -tic TIC              tic
  -v, --verbose         verbose (default=True)
  -a, --save_all        save all available data (default=False)
  -fov                  plot FOV also
  -fov_rad FOV_RAD      FOV radius [arcsec]
  -t, --save_table      summarize TOI info of downloaded files
  -iers                 download iers table
```

Query HARPS database given the target coordinates [deg],
* ./query_harps -ra=279.271 -dec=5.292

Query by TIC or TOI within 10 arcsec,
* ./query_harps -toi=704.01 -d=10

Download specific dataset (e.g. post-upgrade mlc SERVAL) with FOV,
* ./query_harps -toi=704.01 -p=6 -fov

Download all available dataset locally in output folder,
* ./query_harps -toi=704.01 -d=10 -a -o=output

To make a batch script to run `query_harps` given a list of all tics, 
* cat ../data/tics_from_alerts.txt | while read tic; do echo ./query_harps -tic=$tic -d=30 -fov -o=../all_tois -a; done > query_all_toi_harps.batch

To run the N-th line, 
* cat query_all_toi_harps.batch  | sed -n Np | sh

To run all lines in parallel,
cat query_all_toi_harps.batch | parallel

To run new TICS every new release, just copy the tic from the table and save the new list of tics in a .txt file (inside the data directory) and make a new batch script.

Finally, to summarize all the downloaded files in a table,
* ./query_harps -t -o=../all_tois

## Results
* [summary table](https://github.com/jpdeleon/archive_digger/tree/master/all_tois)

## Other RV archives
* [ESO](http://archive.eso.org/cms.html); [script (.py)](http://archive.eso.org/programmatic/eso_ssa.py); [download script (.sh)](http://archive.eso.org/cms/faq/instant-download-how-does-the-download-script-work.html); [scripted access to archive](http://archive.eso.org/programmatic/#SCRIPT)
* [HIRES@KOA](https://koa.ipac.caltech.edu/UserGuide/#hires)
* [SOPHIE/ELODIE](http://atlas.obs-hp.fr/)
* See also [NExSci contributed RV data](https://exoplanetarchive.ipac.caltech.edu/docs/contributed_data.html)

## Documentation (under construction)

Read the docs at [archive_digger.readthedocs.io](http://archive_digger.readthedocs.io/).

## License

<center>
&copy; 2019 Jerome de Leon
</center>

`archive_digger` is a free software made available under the MIT License. For details see
the LICENSE file.
