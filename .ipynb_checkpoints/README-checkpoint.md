# archive_digger
simple query for archival data specific for TESS targets

# test run
* ./query_harps -ra=279.271 -dec=5.292 -d=10 -p=1
* ./query_harps -toi=704.01 -fov -d=10

To remake batch script, try
* cat ../data/tics_from_alerts.txt | while read tic; do echo ./query_harps -tic=$tic -d=10 -o=../all_tois -a; done > query_all_toi_harps.batch

To run N-th line, try
* cat query_all_toi_harps.batch  | sed -n Np | sh

## RV archives
* [ESO](http://archive.eso.org/cms.html); [script (.py)](http://archive.eso.org/programmatic/eso_ssa.py); [download script (.sh)](http://archive.eso.org/cms/faq/instant-download-how-does-the-download-script-work.html); [scripted access to archive](http://archive.eso.org/programmatic/#SCRIPT)
* [HIRES@KOA](https://koa.ipac.caltech.edu/UserGuide/#hires)
* [SOPHIE/ELODIE](http://atlas.obs-hp.fr/)
* See also [NExSci contributed RV data](https://exoplanetarchive.ipac.caltech.edu/docs/contributed_data.html)
