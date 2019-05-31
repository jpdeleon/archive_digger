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
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-05-07T09:50:25.457/ADP.2018-05-07T09:50:25.457.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-04T01:02:11.646/ADP.2018-04-04T01:02:11.646.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.557/ADP.2018-06-05T09:03:13.557.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.711/ADP.2018-06-05T09:03:13.711.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.529/ADP.2018-06-05T09:03:13.529.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.707/ADP.2018-06-05T09:03:13.707.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-11T08:51:51.803/ADP.2018-04-11T08:51:51.803.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-03-18T01:03:03.447/ADP.2018-03-18T01:03:03.447.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-29T01:02:02.836/ADP.2018-04-29T01:02:02.836.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-28T01:03:11.618/ADP.2018-04-28T01:03:11.618.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-05-07T09:50:25.456/ADP.2018-05-07T09:50:25.456.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.712/ADP.2018-06-05T09:03:13.712.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.558/ADP.2018-06-05T09:03:13.558.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-05T01:02:05.110/ADP.2018-04-05T01:02:05.110.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.708/ADP.2018-06-05T09:03:13.708.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-01-28T01:03:26.978/ADP.2018-01-28T01:03:26.978.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-28T01:03:11.617/ADP.2018-04-28T01:03:11.617.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-03-18T01:03:03.448/ADP.2018-03-18T01:03:03.448.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-05-07T09:50:26.271/ADP.2018-05-07T09:50:26.271.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-29T01:02:02.837/ADP.2018-04-29T01:02:02.837.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.523/ADP.2018-06-05T09:03:13.523.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-03-01T01:01:20.191/ADP.2018-03-01T01:01:20.191.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-01-28T01:03:26.977/ADP.2018-01-28T01:03:26.977.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-06T01:02:46.337/ADP.2018-04-06T01:02:46.337.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-05-07T09:50:26.270/ADP.2018-05-07T09:50:26.270.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.524/ADP.2018-06-05T09:03:13.524.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-05T01:02:05.109/ADP.2018-04-05T01:02:05.109.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-06T01:02:46.338/ADP.2018-04-06T01:02:46.338.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-05-07T09:50:26.253/ADP.2018-05-07T09:50:26.253.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.703/ADP.2018-06-05T09:03:13.703.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-11T08:51:52.172/ADP.2018-04-11T08:51:52.172.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-02-27T01:03:13.284/ADP.2018-02-27T01:03:13.284.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-01-26T01:03:21.954/ADP.2018-01-26T01:03:21.954.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-03-06T09:57:34.489/ADP.2018-03-06T09:57:34.489.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-02-24T01:01:35.882/ADP.2018-02-24T01:01:35.882.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-05-07T09:50:26.252/ADP.2018-05-07T09:50:26.252.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.530/ADP.2018-06-05T09:03:13.530.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-03-01T01:01:20.192/ADP.2018-03-01T01:01:20.192.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.704/ADP.2018-06-05T09:03:13.704.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-02-27T01:03:13.283/ADP.2018-02-27T01:03:13.283.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-03-02T01:01:33.757/ADP.2018-03-02T01:01:33.757.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-02-24T01:01:35.881/ADP.2018-02-24T01:01:35.881.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/README_422832/README_422832.txt"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-05-07T09:50:26.263/ADP.2018-05-07T09:50:26.263.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-07T01:02:12.586/ADP.2018-04-07T01:02:12.586.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.721/ADP.2018-06-05T09:03:13.721.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.527/ADP.2018-06-05T09:03:13.527.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-03-06T09:57:34.490/ADP.2018-03-06T09:57:34.490.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-03-02T01:01:33.758/ADP.2018-03-02T01:01:33.758.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-03-17T01:02:32.683/ADP.2018-03-17T01:02:32.683.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-05-07T09:50:26.262/ADP.2018-05-07T09:50:26.262.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-01-27T01:03:28.258/ADP.2018-01-27T01:03:28.258.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-07T01:02:12.585/ADP.2018-04-07T01:02:12.585.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-04T01:02:11.647/ADP.2018-04-04T01:02:11.647.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.722/ADP.2018-06-05T09:03:13.722.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-06-05T09:03:13.528/ADP.2018-06-05T09:03:13.528.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-11T08:51:52.173/ADP.2018-04-11T08:51:52.173.tgz"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-01-26T01:03:21.955/ADP.2018-01-26T01:03:21.955.tar"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-04-11T08:51:51.802/ADP.2018-04-11T08:51:51.802.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-01-27T01:03:28.257/ADP.2018-01-27T01:03:28.257.fits"
"https://dataportal.eso.org/dataPortal/api/requests/jpdeleon/422832/PHASE3/ADP.2018-03-17T01:02:32.682/ADP.2018-03-17T01:02:32.682.fits"

__EOF__
