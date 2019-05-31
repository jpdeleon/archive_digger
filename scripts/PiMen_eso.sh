#!/bin/sh

usage () {
    cat <<__EOF__
usage: $(basename $0) [-hlp] [-u user] [-X args] [-d args]
  -h        print this help text
  -l        print list of files to download
  -p        prompt for password
  -u user   download as a different user
  -X args   extra arguments to pass to xargs
  -d args   extra arguments to pass to the download program

__EOF__
}

username=jpdeleon
xargsopts=
prompt=
list=
while getopts hlpu:xX:d: option
do
    case $option in
    h)  usage; exit ;;
    l)  list=yes ;;
    p)  prompt=yes ;;
    u)  prompt=yes; username="$OPTARG" ;;
    X)  xargsopts="$OPTARG" ;;
    d)  download_opts="$OPTARG";;
    ?)  usage; exit 2 ;;
    esac
done

if test -z "$xargsopts"
then
   #no xargs option speficied, we ensure that only one url
   #after the other will be used
   xargsopts='-L 1'
fi

if [ "$prompt" != "yes" ]; then
   # take password (and user) from netrc if no -p option
   if test -f "$HOME/.netrc" -a -r "$HOME/.netrc"
   then
      grep -ir "dataportal.eso.org" "$HOME/.netrc" > /dev/null
      if [ $? -ne 0 ]; then
         #no entry for dataportal.eso.org, user is prompted for password
         echo "A .netrc is available but there is no entry for dataportal.eso.org, add an entry as follows if you want to use it:"
         echo "machine dataportal.eso.org login jpdeleon password _yourpassword_"
         prompt="yes"
      fi
   else
      prompt="yes"
   fi
fi

if test -n "$prompt" -a -z "$list"
then
    trap 'stty echo 2>/dev/null; echo "Cancelled."; exit 1' INT HUP TERM
    stty -echo 2>/dev/null
    printf 'Password: '
    read password
    echo ''
    stty echo 2>/dev/null
fi

# use a tempfile to which only user has access 
tempfile=`mktemp /tmp/dl.XXXXXXXX 2>/dev/null`
test "$tempfile" -a -f $tempfile || {
    tempfile=/tmp/dl.$$
    ( umask 077 && : >$tempfile )
}
trap 'rm -f $tempfile' EXIT INT HUP TERM

echo "auth_no_challenge=on" > $tempfile
# older OSs do not seem to include the required CA certificates for ESO
echo "check-certificate=off"  >> $tempfile
if [ -n "$prompt" ]; then
   echo "--http-user=$username" >> $tempfile
   echo "--http-password=$password" >> $tempfile

fi
WGETRC=$tempfile; export WGETRC

unset password

if test -n "$list"
then cat
else xargs $xargsopts wget $download_opts 
fi <<'__EOF__'
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:23:20.660/ADP.2014-10-01T10:23:20.660.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:06.557/ADP.2014-10-01T10:21:06.557.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.096/ADP.2018-10-25T01:18:36.096.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:05:19.720/ADP.2014-09-23T11:05:19.720.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:24.857/ADP.2014-10-01T10:21:24.857.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2013-09-27T21:36:00.007/ADP.2013-09-27T21:36:00.007.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:06:01.203/ADP.2014-09-23T11:06:01.203.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2015-11-02T02:01:10.973/ADP.2015-11-02T02:01:10.973.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:25.983/ADP.2014-10-01T10:21:25.983.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:55.313/ADP.2014-10-01T10:20:55.313.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.101/ADP.2018-10-25T01:18:36.101.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.113/ADP.2018-10-25T01:18:36.113.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:15.170/ADP.2014-10-01T10:20:15.170.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-06T10:05:22.663/ADP.2014-10-06T10:05:22.663.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-04-19T01:13:31.355/ADP.2019-04-19T01:13:31.355.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-06T10:05:16.317/ADP.2014-10-06T10:05:16.317.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:04:44.583/ADP.2014-09-23T11:04:44.583.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-03-18T01:03:02.093/ADP.2016-03-18T01:03:02.093.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-03-18T01:03:03.203/ADP.2016-03-18T01:03:03.203.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-16T11:06:08.057/ADP.2014-09-16T11:06:08.057.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:04:30.573/ADP.2014-09-23T11:04:30.573.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-16T11:07:58.883/ADP.2014-09-16T11:07:58.883.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.095/ADP.2018-10-25T01:18:36.095.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2015-01-11T22:55:22.617/ADP.2015-01-11T22:55:22.617.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2013-09-27T21:36:00.293/ADP.2013-09-27T21:36:00.293.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-12-03T19:00:43.450/ADP.2014-12-03T19:00:43.450.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:00:53.917/ADP.2014-09-23T11:00:53.917.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-06T10:08:00.043/ADP.2014-10-06T10:08:00.043.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.100/ADP.2018-10-25T01:18:36.100.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.112/ADP.2018-10-25T01:18:36.112.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:05:38.503/ADP.2014-09-23T11:05:38.503.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-04-19T01:13:31.354/ADP.2019-04-19T01:13:31.354.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-02-06T01:02:20.343/ADP.2016-02-06T01:02:20.343.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:22:52.920/ADP.2014-10-01T10:22:52.920.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-29T13:27:10.337/ADP.2014-09-29T13:27:10.337.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:04.783/ADP.2014-09-23T11:02:04.783.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-07T08:35:35.610/ADP.2014-10-07T08:35:35.610.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:39.603/ADP.2014-09-23T11:03:39.603.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:01:12.470/ADP.2014-09-23T11:01:12.470.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:23:36.477/ADP.2014-10-01T10:23:36.477.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:51.820/ADP.2014-10-01T10:21:51.820.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.094/ADP.2018-10-25T01:18:36.094.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:01:58.560/ADP.2014-09-23T11:01:58.560.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:25.293/ADP.2014-10-01T10:19:25.293.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:20.213/ADP.2014-10-01T10:19:20.213.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:09.420/ADP.2014-10-01T10:21:09.420.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.111/ADP.2018-10-25T01:18:36.111.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.783/ADP.2017-10-26T11:02:52.783.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:48.240/ADP.2014-09-23T11:03:48.240.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:34.113/ADP.2014-09-23T11:02:34.113.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-04-19T01:13:31.357/ADP.2019-04-19T01:13:31.357.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:28.127/ADP.2014-10-01T10:21:28.127.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-07T08:34:43.143/ADP.2014-10-07T08:34:43.143.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-06T10:07:25.670/ADP.2014-10-06T10:07:25.670.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:05:34.427/ADP.2014-09-23T11:05:34.427.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.093/ADP.2018-10-25T01:18:36.093.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:50.070/ADP.2014-10-01T10:19:50.070.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:39.917/ADP.2014-09-23T11:02:39.917.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.122/ADP.2018-10-25T01:18:36.122.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.772/ADP.2017-10-26T11:02:52.772.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2015-11-02T02:01:09.477/ADP.2015-11-02T02:01:09.477.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-04-19T01:13:31.356/ADP.2019-04-19T01:13:31.356.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.716/ADP.2017-10-26T11:02:52.716.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-06T10:04:51.950/ADP.2014-10-06T10:04:51.950.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:04:43.947/ADP.2014-09-23T11:04:43.947.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:28.257/ADP.2014-10-01T10:19:28.257.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:23:14.767/ADP.2014-10-01T10:23:14.767.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-06T10:06:58.710/ADP.2014-10-06T10:06:58.710.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:05:53.287/ADP.2014-09-23T11:05:53.287.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.117/ADP.2018-10-25T01:18:36.117.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-16T11:07:15.307/ADP.2014-09-16T11:07:15.307.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:44.220/ADP.2014-10-01T10:21:44.220.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-24T09:42:40.673/ADP.2014-09-24T09:42:40.673.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:26.910/ADP.2014-10-01T10:19:26.910.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:02.773/ADP.2014-10-01T10:20:02.773.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:51.130/ADP.2014-09-23T11:02:51.130.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:23:37.833/ADP.2014-10-01T10:23:37.833.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-03-18T01:03:02.193/ADP.2016-03-18T01:03:02.193.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:14.123/ADP.2014-10-01T10:20:14.123.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:22:21.190/ADP.2014-10-01T10:22:21.190.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:14.440/ADP.2014-10-01T10:21:14.440.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-12-03T19:00:43.277/ADP.2014-12-03T19:00:43.277.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.104/ADP.2018-10-25T01:18:36.104.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.645/ADP.2017-10-26T11:02:52.645.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.116/ADP.2018-10-25T01:18:36.116.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:52.003/ADP.2014-10-01T10:20:52.003.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.099/ADP.2018-10-25T01:18:36.099.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:04:59.063/ADP.2014-09-23T11:04:59.063.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:23:25.480/ADP.2014-10-01T10:23:25.480.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.807/ADP.2017-10-26T11:02:52.807.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:37.290/ADP.2014-10-01T10:20:37.290.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:58.257/ADP.2014-10-01T10:19:58.257.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:23:24.027/ADP.2014-10-01T10:23:24.027.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:45.867/ADP.2014-09-23T11:02:45.867.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2015-12-02T02:00:52.757/ADP.2015-12-02T02:00:52.757.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:01:14.213/ADP.2014-09-23T11:01:14.213.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-06T10:08:01.393/ADP.2014-10-06T10:08:01.393.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.098/ADP.2018-10-25T01:18:36.098.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-29T13:27:01.943/ADP.2014-09-29T13:27:01.943.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2015-12-02T02:00:53.657/ADP.2015-12-02T02:00:53.657.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2015-01-11T22:55:22.830/ADP.2015-01-11T22:55:22.830.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.103/ADP.2018-10-25T01:18:36.103.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.115/ADP.2018-10-25T01:18:36.115.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-24T09:41:41.500/ADP.2014-09-24T09:41:41.500.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:23:32.127/ADP.2014-10-01T10:23:32.127.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:22:41.093/ADP.2014-10-01T10:22:41.093.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:13.747/ADP.2014-10-01T10:19:13.747.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:37.550/ADP.2014-10-01T10:19:37.550.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.707/ADP.2017-10-26T11:02:52.707.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-07T08:33:50.393/ADP.2014-10-07T08:33:50.393.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:22:12.340/ADP.2014-10-01T10:22:12.340.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-02-06T01:02:20.183/ADP.2016-02-06T01:02:20.183.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/README_422839/README_422839.txt"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:01:29.617/ADP.2014-09-23T11:01:29.617.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:22:17.193/ADP.2014-10-01T10:22:17.193.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.097/ADP.2018-10-25T01:18:36.097.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:03.440/ADP.2014-10-01T10:20:03.440.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2013-09-27T21:36:00.013/ADP.2013-09-27T21:36:00.013.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:00:43.500/ADP.2014-09-23T11:00:43.500.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-16T11:06:46.710/ADP.2014-09-16T11:06:46.710.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.114/ADP.2018-10-25T01:18:36.114.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:01:58.793/ADP.2014-09-23T11:01:58.793.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-01-26T01:13:31.796/ADP.2019-01-26T01:13:31.796.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.102/ADP.2018-10-25T01:18:36.102.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-03-18T01:03:02.200/ADP.2016-03-18T01:03:02.200.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:17.283/ADP.2014-09-23T11:03:17.283.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:13.853/ADP.2014-09-23T11:03:13.853.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:23:16.780/ADP.2014-10-01T10:23:16.780.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-12-07T19:00:31.240/ADP.2014-12-07T19:00:31.240.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-06T10:05:15.903/ADP.2014-10-06T10:05:15.903.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:05:53.567/ADP.2014-09-23T11:05:53.567.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-01-26T01:13:31.795/ADP.2019-01-26T01:13:31.795.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-12-03T19:00:43.870/ADP.2014-12-03T19:00:43.870.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:24.207/ADP.2014-09-23T11:02:24.207.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-07T08:35:21.073/ADP.2014-10-07T08:35:21.073.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:52.733/ADP.2014-10-01T10:21:52.733.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.769/ADP.2017-10-26T11:02:52.769.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:56.513/ADP.2014-09-23T11:03:56.513.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:08.820/ADP.2014-09-23T11:02:08.820.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:31.607/ADP.2014-09-23T11:03:31.607.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:21.083/ADP.2014-09-23T11:02:21.083.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:44.937/ADP.2014-10-01T10:20:44.937.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:05:46.097/ADP.2014-09-23T11:05:46.097.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:22:06.277/ADP.2014-10-01T10:22:06.277.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-07T08:34:47.947/ADP.2014-10-07T08:34:47.947.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-01-26T01:13:31.794/ADP.2019-01-26T01:13:31.794.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.746/ADP.2017-10-26T11:02:52.746.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:22:05.627/ADP.2014-10-01T10:22:05.627.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:42.177/ADP.2014-10-01T10:19:42.177.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:01:50.203/ADP.2014-09-23T11:01:50.203.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:31.927/ADP.2014-09-23T11:02:31.927.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:01:12.357/ADP.2014-09-23T11:01:12.357.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-02-07T01:02:02.120/ADP.2016-02-07T01:02:02.120.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.593/ADP.2017-10-26T11:02:52.593.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-07T08:35:43.487/ADP.2014-10-07T08:35:43.487.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-01-26T01:13:31.793/ADP.2019-01-26T01:13:31.793.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:04:04.017/ADP.2014-09-23T11:04:04.017.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:35.243/ADP.2014-09-23T11:02:35.243.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-11-29T19:00:55.490/ADP.2014-11-29T19:00:55.490.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-03-18T01:03:02.273/ADP.2016-03-18T01:03:02.273.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.119/ADP.2018-10-25T01:18:36.119.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-07T08:35:40.453/ADP.2014-10-07T08:35:40.453.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-12-07T19:00:31.067/ADP.2014-12-07T19:00:31.067.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.691/ADP.2017-10-26T11:02:52.691.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:32.507/ADP.2014-10-01T10:21:32.507.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:27.410/ADP.2014-10-01T10:21:27.410.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:04.037/ADP.2014-09-23T11:02:04.037.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.647/ADP.2017-10-26T11:02:52.647.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:06:05.930/ADP.2014-09-23T11:06:05.930.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:42.227/ADP.2014-09-23T11:02:42.227.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-01-26T01:13:31.792/ADP.2019-01-26T01:13:31.792.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:23:39.823/ADP.2014-10-01T10:23:39.823.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:11.740/ADP.2014-09-23T11:03:11.740.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:01:45.560/ADP.2014-09-23T11:01:45.560.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:18.163/ADP.2014-10-01T10:20:18.163.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-02-07T01:02:01.813/ADP.2016-02-07T01:02:01.813.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.118/ADP.2018-10-25T01:18:36.118.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:01.563/ADP.2014-09-23T11:03:01.563.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:15.383/ADP.2014-10-01T10:21:15.383.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-02-22T01:36:12.436/ADP.2019-02-22T01:36:12.436.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:11.560/ADP.2014-09-23T11:03:11.560.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.672/ADP.2017-10-26T11:02:52.672.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:22:51.933/ADP.2014-10-01T10:22:51.933.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:22:40.107/ADP.2014-10-01T10:22:40.107.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-01-26T01:13:31.791/ADP.2019-01-26T01:13:31.791.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:36.417/ADP.2014-09-23T11:03:36.417.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.121/ADP.2018-10-25T01:18:36.121.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-11-29T19:00:55.783/ADP.2014-11-29T19:00:55.783.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-12-03T19:00:43.357/ADP.2014-12-03T19:00:43.357.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-04-19T01:13:31.359/ADP.2019-04-19T01:13:31.359.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:51.120/ADP.2014-09-23T11:03:51.120.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:52.763/ADP.2014-10-01T10:20:52.763.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-16T11:03:38.953/ADP.2014-09-16T11:03:38.953.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:04:24.913/ADP.2014-09-23T11:04:24.913.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:01:14.593/ADP.2014-09-23T11:01:14.593.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:39.600/ADP.2014-09-23T11:02:39.600.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-02-22T01:36:12.435/ADP.2019-02-22T01:36:12.435.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:58.577/ADP.2014-10-01T10:20:58.577.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2018-10-25T01:18:36.120/ADP.2018-10-25T01:18:36.120.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:04:34.423/ADP.2014-09-23T11:04:34.423.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:22:24.907/ADP.2014-10-01T10:22:24.907.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:09.120/ADP.2014-10-01T10:20:09.120.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-04-19T01:13:31.358/ADP.2019-04-19T01:13:31.358.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:56.690/ADP.2014-10-01T10:19:56.690.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:00:57.817/ADP.2014-09-23T11:00:57.817.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-02-22T01:36:12.434/ADP.2019-02-22T01:36:12.434.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:36.097/ADP.2014-10-01T10:21:36.097.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.682/ADP.2017-10-26T11:02:52.682.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2013-09-27T21:36:00.173/ADP.2013-09-27T21:36:00.173.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:04:58.623/ADP.2014-09-23T11:04:58.623.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:54.827/ADP.2014-10-01T10:21:54.827.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:04:40.237/ADP.2014-09-23T11:04:40.237.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:02:09.173/ADP.2014-09-23T11:02:09.173.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:06:09.307/ADP.2014-09-23T11:06:09.307.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:08.240/ADP.2014-10-01T10:19:08.240.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.638/ADP.2017-10-26T11:02:52.638.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-02-06T01:02:20.277/ADP.2016-02-06T01:02:20.277.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-07T08:34:36.827/ADP.2014-10-07T08:34:36.827.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2019-02-22T01:36:12.433/ADP.2019-02-22T01:36:12.433.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:19:27.023/ADP.2014-10-01T10:19:27.023.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-02-06T01:02:20.090/ADP.2016-02-06T01:02:20.090.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:00:50.317/ADP.2014-09-23T11:00:50.317.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:35.083/ADP.2014-09-23T11:03:35.083.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:05.777/ADP.2014-10-01T10:21:05.777.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:01:23.090/ADP.2014-09-23T11:01:23.090.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-16T11:03:42.747/ADP.2014-09-16T11:03:42.747.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:21:11.563/ADP.2014-10-01T10:21:11.563.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:04:59.057/ADP.2014-09-23T11:04:59.057.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:05:54.537/ADP.2014-09-23T11:05:54.537.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-10-01T10:20:21.863/ADP.2014-10-01T10:20:21.863.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2016-03-18T01:03:03.937/ADP.2016-03-18T01:03:03.937.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-24T09:44:55.510/ADP.2014-09-24T09:44:55.510.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:03:37.023/ADP.2014-09-23T11:03:37.023.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.586/ADP.2017-10-26T11:02:52.586.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-24T09:43:53.667/ADP.2014-09-24T09:43:53.667.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2014-09-23T11:00:36.387/ADP.2014-09-23T11:00:36.387.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422839/PHASE3/ADP.2017-10-26T11:02:52.627/ADP.2017-10-26T11:02:52.627.fits"

__EOF__
