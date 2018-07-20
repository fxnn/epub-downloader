#!/bin/bash

set -e
baseUrl=$1

function getDirName() {
    echo $1 | sed -e 's_^\(.*\)/[^/]*$_\1_g'
}
function download() {
    dirName=$(getDirName $1)
    if [[ "x$dirName" != "x" ]]; then
        mkdir -p $dirName
    fi

    # -nv: no verbose
    # -O: output file name
    wget -nv -O "$1" "$baseUrl/$1"
}
function getRootFilePath() {
    xpath -q -e '//rootfile/@full-path' $1 | sed -e 's/^.*"\(.*\)".*$/\1/g'
}
function getItemPaths() {
    xpath -q -e '//manifest/item/@href' $1 | sed -e 's/^.*"\(.*\)".*$/\1/g'
}

download mimetype
download META-INF/container.xml

rootFilePath=$(getRootFilePath META-INF/container.xml)
download $rootFilePath

itemDir=$(getDirName $rootFilePath)
for itemPath in $(getItemPaths $rootFilePath) ; do
	download $itemDir/$itemPath
done

zip -r output.epub ./*

