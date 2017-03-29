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

${DOCKER} commit step1 oracle-12c:committed
${DOCKER} create --shm-size=4g -ti --name committed oracle-12c:committed /bin/bash
${DOCKER} export committed | ${DOCKER} import - oracle-12c:installed || {
    echo "Erro durante o import"
    exit 1
}

${DOCKER} build -t oracle-12c:step2 step2
${DOCKER} create --shm-size=4g -ti --name step2 oracle-12c:step2 /bin/bash && {
    ${DOCKER} container rm committed
    ${DOCKER} container rm step1

    ${DOCKER} rmi oracle-12c:installed
    ${DOCKER} rmi oracle-12c:committed
    ${DOCKER} rmi oracle-12c:step1

    ${DOCKER} image prune -f
}

${DOCKER} start step2
${DOCKER} exec -it step2 /tmp/create 
${DOCKER} stop step2

${DOCKER} commit step2 oracle-12c:committed
${DOCKER} create --shm-size=4g -ti --name committed oracle-12c:committed /bin/bash

${DOCKER} export committed | ${DOCKER} import - oracle-12c:created || {
    echo "Erro durante o import"
    exit 1
}

${DOCKER} build -t oracle-12c step3
${DOCKER} create --shm-size=4g -ti --name oracle-12c oracle-12c:latest /tmp/start && {
    ${DOCKER} container rm committed
    ${DOCKER} container rm step2

    ${DOCKER} rmi oracle-12c:created
    ${DOCKER} rmi oracle-12c:committed
    ${DOCKER} rmi oracle-12c:step2

    ${DOCKER} image prune -f
}

${DOCKER} start oracle-12c
