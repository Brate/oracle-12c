#!/bin/bash

ORA_112040=13390677
ORA_121020=21419221

PREF=`basename $0`
CD=`dirname $0`
CFG=${CD}/.${PREF}.cfg
TMP1=${CD}/.${PREF}.tmp1
TMP2=${CD}/.${PREF}.tmp2
COOK=${CD}/.${PREF}.cookies

trap 'rm -f ${TMP1} ${TMP2} ${COOK} 2> /dev/null; exit 1' 0 1 9 15 

loginMOS() {
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
}

PLATLANG=226P

echo
# echo "Downloading the patches:"
for URL in $(< ${CD}/files/ORA_112040.url)
do
    fname=`echo ${URL} | awk -F"=" '{print $NF;}' | sed "s/[?&]//g"`
    download=true

    if [ -f files/${fname} ]; then
        echo -n "MD5 ${fname}... "
        md5=$(grep ${fname} ${CD}/files/ORA_112040.md5 | awk '{print $2}')
        fmd5=$(openssl dgst -md5 ${CD}/files/${fname}  | awk '{print $2}')

        if [ "X"$md5 == "X"$fmd5 ]; then
            download=false
            echo "OK"
        fi
    fi

    if [ "X"$download == "X"true ]; then
        [ -f ${COOK} ] || loginMOS

        echo "Downloading file $fname ..."
        curl -b $COOK -c $COOK --tlsv1 --insecure --user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/601.7.7 (KHTML, like Gecko) Version/9.1.2 Safari/601.7.7" --output ${CD}/files/$fname -L "${URL}&userid=o-${mosUser}&email=${mosUser}&patch_password="
        echo "$fname completed with status: $?"
    fi
done
