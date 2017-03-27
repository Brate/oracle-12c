#!/bin/bash

DOCKER=$(which docker)
CWD=$(pwd)

[ -z "${DOCKER}" ] && { echo "Docker not found"; exit 1; }

ln -f $CWD/files/p21419221_121020_Linux-x86-64_1of10.zip $CWD/step1/p21419221_121020_Linux-x86-64_1of10.zip
ln -f $CWD/files/p21419221_121020_Linux-x86-64_2of10.zip $CWD/step1/p21419221_121020_Linux-x86-64_2of10.zip
ln -f $CWD/files/p21419221_121020_Linux-x86-64_3of10.zip $CWD/step1/p21419221_121020_Linux-x86-64_3of10.zip

${DOCKER} build -t oracle-12c:step1 step1
${DOCKER} create --shm-size=4g -ti --name step1 oracle-12c:step1 /bin/bash
${DOCKER} start step1

${DOCKER} exec -it step1 /tmp/install/install 
${DOCKER} stop step1
${DOCKER} commit step1 oracle-12c:installed && {
    IID=$(docker images | awk '/step1/ { print $3 }')
    if [ -n "${IID}" ] ; then
        ${DOCKER} rmi ${IID}
    fi
}

${DOCKER} build -t oracle-12c:step2 step2 && {
    IID=$(docker images | awk '/installed/ { print $3 }')
    if [ -n "${IID}" ] ; then
        ${DOCKER} rmi ${IID}
    fi
}
${DOCKER} create --shm-size=4g -ti --name step2 oracle-12c:step2 /bin/bash
${DOCKER} start step2

${DOCKER} exec -it step2 /tmp/create 
${DOCKER} stop step2
${DOCKER} commit step2 oracle-12c:created && {
    IID=$(docker images | awk '/step2/ { print $3 }')
    if [ -n "${IID}" ] ; then
        ${DOCKER} rmi ${IID}
    fi
}

${DOCKER} build -t oracle-12c step3
${DOCKER} create --shm-size=4g -ti --name oracle-12c oracle-12c:latest 


#docker run --shm-size=4g -ti --name step1 oracle-12c:step1 /bin/bash /tmp/install/install
