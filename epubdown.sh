#!/bin/bash

set -e
#set -o xtrace
baseUrl=$1
targetName=$2

function getDirName() {
    result=$(echo $1 | sed -e 's_^\(.*\)/[^/]*$_\1_g')
    if [[ "$result" != "$1" ]]; then
	echo $result
    fi
}
function download() {
    dirName=$(getDirName $1)
    if [[ "x$dirName" != "x" ]]; then
        mkdir -p "${targetName}/${dirName}"
    fi

    # -nv: no verbose
    # -O: output file name
    wget -nv -O "${targetName}/$1" "$baseUrl/$1"
}
function getRootFilePath() {
    xpath -q -e '//rootfile/@full-path' "${targetName}/$1" | sed -e 's/^.*"\(.*\)".*$/\1/g'
}
function getItemPaths() {
    xpath -q -e '//manifest/item/@href' "${targetName}/$1" | sed -e 's/^.*"\(.*\)".*$/\1/g'
}

mkdir -p "${targetName}"
download mimetype
download META-INF/container.xml

rootFilePath=$(getRootFilePath META-INF/container.xml)
download $rootFilePath

itemDir=$(getDirName $rootFilePath)
for itemPath in $(getItemPaths $rootFilePath) ; do
	download $itemDir/$itemPath
done

( cd "${targetName}" && zip -r "../${targetName}.epub" ./* )

