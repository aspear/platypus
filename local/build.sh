#!/bin/bash

set -x

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

OUTPUT_DIR=${SCRIPT_DIR}/staging

TOOLS_DIR=${SCRIPT_DIR}/tools

APIX_SERVER=https://vdc-repo.vmware.com

export VER="0.0.28"
APIX_RELEASE_URL=https://github.com/vmware/api-explorer/releases/download/${VER}

if [ ! -f api-explorer-dist-${VER}.zip ]; then
    wget --no-check-certificate ${APIX_RELEASE_URL}/api-explorer-dist-${VER}.zip
fi

if [ ! -f api-explorer-tools-${VER}.zip ]; then
    wget --no-check-certificate ${APIX_RELEASE_URL}/api-explorer-tools-${VER}.zip
fi

if [ -d "${SCRIPT_DIR}/tools" ]; then
    echo "Already staged tools"
else
    echo "Staging tools"
    mkdir -p ${SCRIPT_DIR}/tools
    pushd ${SCRIPT_DIR}/tools
	
    unzip ${SCRIPT_DIR}/api-explorer-tools-*.zip

    popd
fi

# remove all of the locally generated files.
rm -rf ${OUTPUT_DIR}/*
mkdir -p ${OUTPUT_DIR}/local/swagger

pushd ${OUTPUT_DIR}

echo "extracting APIX distribution"
unzip ${SCRIPT_DIR}/api-explorer-dist-*.zip

echo "overwriting config with local config"
cp -f ${SCRIPT_DIR}/config.js .

# run the tool to stage the swagger json files from the 
# ${SCRIPT_DIR}/swagger directory to the local/swagger
# directory abbreviating the descriptions and then also 
# generating overview HTML next to the json files.  when it does
# this it generates an "overview" resource in the local.json file
# that has all of the configuration in it

echo "staging local vRA API content"
python ${TOOLS_DIR}/apixlocal/apixlocal.py \
 stage \
 --server=${APIX_SERVER} \
 --html_root_dir=${OUTPUT_DIR} \
 --output_file=${OUTPUT_DIR}/local.json  \
 --abbreviate_description \
 --generate_overview_html \
 --product_name="vRealize Automation;7.3.0" \
 --api_version="(vRA 7.3.0)" \
 --swagger_glob ${SCRIPT_DIR}/swagger/api*.json \
 --swagger_output_dir=${OUTPUT_DIR}/local/swagger \

popd
