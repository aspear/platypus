#!/bin/bash

set -x

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

TOOLS_DIR=${SCRIPT_DIR}/tools
rm -rf ${TOOLS_DIR}

export VER="0.0.8"

if [ ! -f api-explorer-dist-${VER}.zip ]; then
    wget https://github.com/vmware/api-explorer/releases/download/${VER}/api-explorer-dist-${VER}.zip
fi

if [ ! -f api-explorer-tools-${VER}.zip ]; then
    wget https://github.com/vmware/api-explorer/releases/download/${VER}/api-explorer-tools-${VER}.zip
fi

mkdir -p ${SCRIPT_DIR}/tools
pushd ${SCRIPT_DIR}/tools
unzip ${SCRIPT_DIR}/api-explorer-tools-*.zip
popd

OUTPUT_DIR=${SCRIPT_DIR}/staging

# remove all of the locally generated files.
rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}/local/swagger

pushd ${OUTPUT_DIR}

unzip ${SCRIPT_DIR}/api-explorer-dist-*.zip

#overwrite config with vRA config
cp -f ${SCRIPT_DIR}/config.js .

# run the tool to stage the swagger json files from the 
# ${SCRIPT_DIR}/swagger-vra directory to the local/swagger
# directory abbreviating the descriptions and then also 
# generating overview HTML next to the json files.  when it does
# this it generates an "overview" resource in the local.json file
# that has all of the configuration in it

python ${TOOLS_DIR}/apiFilesToLocalJson.py \
 --abbreviateDescription \
 --generateOverviewHtml \
 --apiPrepend="vRealize Automation " \
 --productName="vRealize Automation;7.3.0" \
 --apiVersion="(vRealize Automation 7.3.0)" \
 --swaggerglob ${SCRIPT_DIR}/swagger-vra/api*.json \
 --outdir=${OUTPUT_DIR}/local/swagger \
 --htmlRootDir ${OUTPUT_DIR} \
 --outfile ${OUTPUT_DIR}/local.json

popd
