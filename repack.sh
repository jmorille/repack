#!/bin/bash -e

VERSION="0.21.0"
DIR_HOME=$PWD
DIR_TODO="todo"
DIR_UNTAR="working-untar"
DIR_RETAR="final"

downloadHelp() {
  echo "--- ---------------------------------------------- ---"
  echo "--- Prometheus       : https://prometheus.io/download/"
  echo "--- PHP-FPM Exporter : https://github.com/bakins/php-fpm-exporter/releases"
  echo "--- ---------------------------------------------- ---"
}

init () {
  downloadHelp
  cleanWorking
  cleanFinal
}

initUnpack () {
  cleanWorking
}

cleanTodo () {
  echo "--- Clean Todo Directory $DIR_TODO"
  echo "--- ---------------------------------------------- ---"
  cd ${DIR_HOME}
  rm -rf ${DIR_TODO}/*
  mkdir -p ${DIR_TODO}
}

cleanWorking () {
  echo "--- Clean Working Directory $DIR_UNTAR"
  echo "--- ---------------------------------------------- ---"
  cd ${DIR_HOME}
  rm -rf ${DIR_UNTAR}
  mkdir -p ${DIR_UNTAR}
}


cleanFinal () {
  echo "--- Clean Final Directory $DIR_RETAR"
  echo "--- ---------------------------------------------- ---"
  cd ${DIR_HOME}
  rm -rf ${DIR_RETAR}/*.tar.gz
  mkdir -p ${DIR_RETAR}
}

# curl https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
# curl https://github.com/prometheus/alertmanager/releases/download/v${VERSION}/alertmanager-${VERSION}.linux-amd64.tar.gz
# PHP-FPM Exporter : https://github.com/bakins/php-fpm-exporter/releases

unpack () {
  echo "Woring Directory $DIR_HOME"
  unpackTarGz
  unpackZip
  unpackBinary
}

unpackBinary () {
  cd ${DIR_TODO}
  for file in *.amd64;
  do
    [ -e "$file" ] || continue
    echo "--- Processing Binary $file file.."
    echo "--- ---------------------------------------------- ---"  
    mkdir -p $DIR_HOME/${DIR_UNTAR}/${file}
    cp ${file} $DIR_HOME/${DIR_UNTAR}/${file}
    rm -rf ${file}
    echo "--- Processing Binary $file file.. End";
    echo "--- ---------------------------------------------- ---"  
  done
  cd ${DIR_HOME}
}


unpackTarGz () {
  echo "--- ---------------------------------------------- ---"
  echo "---                    Unpack TAR GZ               ---"
  echo "--- ---------------------------------------------- ---"  
  for file in ${DIR_TODO}/*.tar.gz;
  do
    [ -e "$file" ] || continue
    echo "--- Unpack Tar.gz $file file..";
    echo "--- ---------------------------------------------- ---"  
    tar -xzf ${file} -C ${DIR_HOME}/${DIR_UNTAR}/
    rm -rf ${file}
    echo "--- Unpack Tar.gz $file file.. End";
    echo "--- ---------------------------------------------- ---"  
  done
  cd ${DIR_HOME}
}

unpackZip () {
  echo "--- ---------------------------------------------- ---"
  echo "---                    Unpack ZIP                  ---"
  echo "--- ---------------------------------------------- ---"  
  for file in ${DIR_TODO}/*.zip;
  do
    [ -e "$file" ] || continue
    echo "--- Unpack Zip $file file..";
    echo "--- ---------------------------------------------- ---"  
    unzip ${file} -d ${DIR_HOME}/${DIR_UNTAR}/
    rm -rf ${file}
    echo "--- Unpack Zip $file file.. End";
    echo "--- ---------------------------------------------- ---"  
  done
  cd ${DIR_HOME}
}


repack () {
  echo "--- ---------------------------------------------- ---"
  echo "---                    Repack                      ---"
  echo "--- ---------------------------------------------- ---"  
  cd  ${DIR_HOME}/${DIR_UNTAR}
  for file in *;
  do
    [ -d "$file" ] || continue
    echo "--- Repack $file directory..";
    echo "--- ---------------------------------------------- ---"  
    cd ${DIR_HOME}/${DIR_UNTAR}/${file}
    tar -czvf ${DIR_HOME}/${DIR_RETAR}/${file}.tar.gz *
    cd  ${DIR_HOME}/${DIR_UNTAR}
    #rm -rf ${file}
    echo "--- Repack $file directory.. End";
    echo "--- ---------------------------------------------- ---"  
  done
  cd ${DIR_HOME}
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
