#!/bin/bash

set -e
#set -o xtrace

#
# Args

baseUrl=$1 ; shift
targetFilename=$1 ; shift
if [ -n "$1" ]; then
	workingDirPath="$1"
	shift
else
	workDirPath=$(mktemp -d)
fi

if [ -z "$baseUrl" -o -z "$targetFilename" ]; then
	echo "usage: $0 baseUrl targetFilename [workingDirPath]"
	exit 1
fi

#
# Functions

function getDirName() {
    result=$(echo $1 | sed -e 's_^\(.*\)/[^/]*$_\1_g')
    if [[ "$result" != "$1" ]]; then
	echo $result
    fi
}
function download() {
    dirName=$(getDirName $1)
    if [[ "x$dirName" != "x" ]]; then
        mkdir -p "${workDirPath}/${dirName}"
    fi

    # -nv: no verbose
    # -O: target filename
    wget -nv -O "${workDirPath}/$1" "$baseUrl/$1"
}
function getRootFilePath() {
    xpath -q -e '//rootfile/@full-path' "${workDirPath}/$1" | sed -e 's/^.*"\(.*\)".*$/\1/g'
}
function getItemPaths() {
    xpath -q -e '//manifest/item/@href' "${workDirPath}/$1" | sed -e 's/^.*"\(.*\)".*$/\1/g'
}

#
# Main

echo >&2
echo Downloading EPUB file. >&2
echo - Base URL: ${baseUrl} >&2
echo - Working Directory: ${workDirPath} >&2
echo >&2

download mimetype
download META-INF/container.xml

rootFilePath=$(getRootFilePath META-INF/container.xml)
download $rootFilePath

itemDir=$(getDirName $rootFilePath)
for itemPath in $(getItemPaths $rootFilePath) ; do
	download $itemDir/$itemPath
done

echo >&2
echo Packing EPUB file. >&2
echo - Working Directory: ${workDirPath} >&2
echo - Target Filename: ${targetFilename} >&2
echo >&2

( cd "${workDirPath}" && zip -r "${targetFilename}" ./* )

echo >&2
echo Removing Working Directory. >&2

rm -Rf "${workDirPath}"

echo >&2
echo Done. >&2
echo >&2

