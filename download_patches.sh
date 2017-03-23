#!/bin/sh

ORA_112040=13390677
ORA_121020=21419221

PREF=`basename $0`
CD=`dirname $0`
CFG=${CD}/.${PREF}.cfg
COOK=${CD}/.${PREF}.cookies

# Reading the MOS user credentials. Set environment variables mosUser and mosPass if you want to skip this.
[ -z "$mosUser" ] && read -p "Oracle Support Userid: " mosUser
[ -z "$mosPass" ] && read -sp "Oracle Support Password: " mosPass
echo
touch ~/.wgetrc
chmod 600 ~/.wgetrc
perl -pi -e 'if(/^user=/){undef $_}' ~/.wgetrc
perl -pi -e 'if(/^password=/){undef $_}' ~/.wgetrc
echo "user=$mosUser" >> ~/.wgetrc
echo "password=$mosPass" >> ~/.wgetrc
set +e
wget --secure-protocol=TLSv1 --save-cookies=$COOK --keep-session-cookies --no-check-certificate "https://updates.oracle.com/Orion/SimpleSearch/switch_to_saved_searches" -O $TMP1 -o $TMP2 --no-verbose
RESULT=$?
perl -pi -e 'if(/^user=/){undef $_}' ~/.wgetrc
perl -pi -e 'if(/^password=/){undef $_}' ~/.wgetrc
if [ ${RESULT} -ne 0 ] ; then
    cat $TMP2
    exit 1
fi

PLATLANG=226P

echo
echo "Downloading the patches:"
for URL in $(cat ORA_112040.url)
do
    fname=`echo ${URL} | awk -F"=" '{print $NF;}' | sed "s/[?&]//g"`
    echo "Downloading file $fname ..."
    curl -b $COOK -c $COOK --tlsv1 --insecure --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/601.7.7 (KHTML, like Gecko) Version/9.1.2 Safari/601.7.7" --output $fname -L "${URL}&userid=o-${mosUser}&email=${mosUser}&patch_password="
    echo "$fname completed with status: $?"
done
