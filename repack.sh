#!/bin/bash

VERSION="0.21.0"
DIR_UNTAR="untar"
DIR_RETAR="retar"

init () {
  initUnpack
  initRepack
}

initUnpack () {
  rm -rf ${DIR_UNTAR}
  mkdir ${DIR_UNTAR}
}

initRepack () {
  rm -rf ${DIR_RETAR}
  mkdir ${DIR_RETAR}
}
# curl https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
# curl https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.linux-amd64.tar.gz

unpack () {
  for file in *.tar.gz
  do
    echo "Processing $file file..";
    tar -xzf ${file} -C ${DIR_UNTAR}/
    echo "Processing $file file.. End";
  done
}

repack () {
  initRepack
  cd ${DIR_UNTAR}
  for file in *
  do
    echo "Processing $file directory..";
    cd ${file}
    tar -czvf ../../${DIR_RETAR}/${file}.tar.gz *
    cd ..
    echo "Processing $file directory.. End";
  done
  cd ..
}

NEXUS_BASEURL='http://nexus.agrica.loc'
NEXUS_PASSWORD='admin:admin123'
GROUP_ID="org.prometheus"

mavenDeploy () {
  cd ${DIR_RETAR}
  for file in *
  do
    echo "Processing $file repack..";
    readarray -d - -t arr <<<"${file}"
    artifactId=${arr[0]}
    echo "Artefact=${artifactId}"
    echo curl -v -F r=releases -F hasPom=false -F e=jar -F g=${GROUP_ID} -F a=${artifactId} -F v=${VERSION} -F p=jar -F file=@p${file} -u ${NEXUS_PASSWORD} ${NEXUS_BASEURL}/nexus/service/local/artifact/maven/content
    echo "Processing $file repack.. End";
  done
  cd ..
}

init
unpack
repack
mavenDeploy
