#!/bin/bash
set -e

CWD=$(pwd)
FORCE="0"
RUNTIME="node"
ZIP_SHA256=""

PACKJSON=package.json
if [[ ! -f "$PACKJSON" ]]
then
    echo "package.json not found"
    exit 1
fi

if [[ -z "$DESTINATION" ]]
then
    echo "destination is required!"
    exit 1
fi

if [[ -z "$ZIPNAME" ]]
then
    ZIPNAME="dist.zip"
fi

mkdir -p $DESTINATION

# analisa se existe arquivo checksum
FILESHA256="checksum"

# gerando um checksum atual do projeto
for file in $(find . -maxdepth 1 -type f -name "*.js"); do
    if [[ -f $file ]]
    then
        filename=$(basename $file)
        filesha256sum=$(cat $filename | sha256sum | cut -d " " -f 1)
        STR+="$filesha256sum\n"
    fi
done

# limpando quebras de linhas desnecessarias
STR=${STR::-2}

# gravando com interpolacao ativada
echo -e "$STR" >>"checksum.tmp"

# gravando na memoria resultado do checksum atual
CHECKSUM_MEMORY=$(cat checksum.tmp | sha256sum | cut -d " " -f 1)

# deletando checksum temporario
rm -f checksum.tmp

# verifica se existe um arquivo checksum, caso nao gera um
if ! [ -f $FILESHA256 ]; then
    echo "$CHECKSUM_MEMORY" >>"checksum"
    FORCE="1"
fi

if [[ $(cat $FILESHA256) == $CHECKSUM_MEMORY && $FORCE == "0" ]]; then
    FORCE="0"
else
    FORCE="1"
fi

# gerando novo ZIP formato nodejs
if [[ $FORCE == "1" && "$RUNTIME" == *"node"* ]]; then
    rm -f $ZIPNAME
    rm -f package-lock.json
    rm -rf "node_modules"
    
    echo "$CHECKSUM_MEMORY" >"checksum"
    
    npm install --production
    zip -rqX $ZIPNAME node_modules/ *.js

    ZIP_SHA256=$(cat $ZIPNAME | openssl dgst -binary -sha256 | openssl base64)

    ls -lha

    mv $ZIPNAME $DESTINATION/

    ls -lha $DESTINATION/
    
    echo "$ZIP_SHA256" >"sha256zip"
fi

if [[ $FORCE == "0" ]]; then
    ZIP_SHA256=$(cat sha256zip)
fi

rm -rf "node_modules"
rm -f package-lock.json

echo ::set-output name=source_code_hash::$ZIP_SHA256