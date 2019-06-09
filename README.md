# archive_digger
================
simple query for archival radial velocity data of TESS targets

[![Documentation Status](https://readthedocs.org/projects/archive-digger/badge/?version=latest)](https://archive-digger.readthedocs.io/en/latest/?badge=latest)
[![license](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/dfm/emcee/blob/master/LICENSE)

# test run
By coordinates,
* ./query_harps -ra=279.271 -dec=5.292 -d=10 -p=1
By TIC or TOI,
* ./query_harps -toi=704.01 -fov -d=10


To remake batch script, 
* cat ../data/tics_from_alerts.txt | while read tic; do echo ./query_harps -tic=$tic -d=30 -fov -o=../all_tois -a; done > query_all_toi_harps.batch

To run N-th line, 
* cat query_all_toi_harps.batch  | sed -n Np | sh

To run all in parallel,
cat query_all_toi_harps.batch | parallel

To run new TOI every new release, just copy the tic from the table and save it in a .txt file in data directory and follow the instructions above.

## RV archives
* [ESO](http://archive.eso.org/cms.html); [script (.py)](http://archive.eso.org/programmatic/eso_ssa.py); [download script (.sh)](http://archive.eso.org/cms/faq/instant-download-how-does-the-download-script-work.html); [scripted access to archive](http://archive.eso.org/programmatic/#SCRIPT)
* [HIRES@KOA](https://koa.ipac.caltech.edu/UserGuide/#hires)
* [SOPHIE/ELODIE](http://atlas.obs-hp.fr/)
* See also [NExSci contributed RV data](https://exoplanetarchive.ipac.caltech.edu/docs/contributed_data.html)

Documentation
-------------

Read the docs at `archive_digger.readthedocs.io <http://archive_digger.readthedocs.io/>`_.

License
-------

<center>
&copy; 2019 Jerome de Leon
</center>

archive_digger is a free software made available under the MIT License. For details see
the LICENSE file.
