#!/bin/bash -e

VERSION="0.21.0"
DIR_HOME=$PWD
DIR_TODO="todo"
DIR_UNTAR="working-untar"
DIR_RETAR="final"

init () {
  cleanWorking
  cleanFinal
}

initUnpack () {
  cleanWorking
}

cleanTodo () {
  echo "Clean Todo Directory $DIR_TODO"
  rm -rf ${DIR_TODO}/*
  mkdir -p ${DIR_TODO}
}

cleanWorking () {
  echo "Clean Working Directory $DIR_UNTAR"
  rm -rf ${DIR_UNTAR}
  mkdir -p ${DIR_UNTAR}
}


cleanFinal () {
  echo "Clean Final Directory $DIR_RETAR"
  rm -rf ${DIR_RETAR}/*.tar.gz
  mkdir -p ${DIR_RETAR}
}

# curl https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
# curl https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.linux-amd64.tar.gz
# PHP-FPM Exporter : https://github.com/bakins/php-fpm-exporter/releases

unpack () {
  echo "Woring DIrectory $DIR_HOME"
  unpackTarGz
  unpackBinary
}

unpackBinary () {
  cd ${DIR_TODO}
  for file in *.amd64
  do
    echo "Processing $file file..";
    mkdir -p $DIR_HOME/${DIR_UNTAR}/${file}
    cp ${file} $DIR_HOME/${DIR_UNTAR}/${file}
    echo "Processing $file file.. End";
  done
  cd $DIR_HOME
}


unpackTarGz () {
  for file in ${DIR_TODO}/*.tar.gz
  do
    echo "Processing $file file..";
    tar -xzf ${file} -C ${DIR_UNTAR}/
    echo "Processing $file file.. End";
  done
}

repack () {
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
cleanWorking
cleanTodo
# mavenDeploy
