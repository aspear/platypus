#!/bin/bash

###############################################################################
# Copyright VMware, Inc. 2017. All Rights Reserved.
# SPDX-License-Identifier: MIT
#
# You are free to use this file under the terms of the MIT open source license,
# see LICENSE in the root of the containing project.
#
# DISCLAIMER. THIS PROGRAM IS PROVIDED TO YOU "AS IS" WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, WHETHER ORAL OR WRITTEN,
# EXPRESS OR IMPLIED. THE AUTHOR SPECIFICALLY DISCLAIMS ANY IMPLIED
# WARRANTIES OR CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY,
# NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE.
#
# This script builds an web server image in the file system of VMware API
# Explorer (https://github.com/vmware/api-explorer), that is customized in this 
# file with specific API references.  This image can then be served from any 
# web container (tomcat, apache, NGINX, ...)
#
# VALUES THAT MUST BE CHANGED:
# -At the bottom the apixlocal command run references string values specific
# to the local APIs, these must be changed for every differnet package.
# - the config.js file contains string and configuration values that are 
# specific to a given set of APIs as well and should be customized.
###############################################################################

set -x  # fail the script if any command fails
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

# -----------------------------------------------------------------------------
# VARIABLES YOU CAN SET

# you can supply an overridden build directory via BUILD_DIR variable if you 
# wish.  If not provided, all output is created in this (the script) directory.
BUILD_DIR=${BUILD_DIR:-${SCRIPT_DIR}}

APIX_SERVER=https://vdc-repo.vmware.com

# the VER variable is the one place to change the particular release of API 
# explorer.  See https://github.com/vmware/api-explorer/releases for valid 
# values
# these were the airwatch values export VER="1.0.0"
#export MILESTONE="rc3"
#export VER="1.1.1"
#export MILESTONE="rc2"

export VER="1.1.3"
export MILESTONE=""

# -----------------------------------------------------------------------------
APIX_RELEASE_URL=https://github.com/vmware/api-explorer/releases/download/${VER}${MILESTONE}

OUTPUT_DIR=${BUILD_DIR}/staging
TOOLS_DIR=${BUILD_DIR}/tools
DOWNLOAD_DIR=${BUILD_DIR}/download

mkdir -p ${DOWNLOAD_DIR}

# download zips of the distribution and tools if not cached locally
if [ ! -f ${DOWNLOAD_DIR}/api-explorer-dist-${VER}.zip ]; then
    wget --no-check-certificate ${APIX_RELEASE_URL}/api-explorer-dist-${VER}.zip --output-document ${DOWNLOAD_DIR}/api-explorer-dist-${VER}.zip
fi

if [ ! -f ${DOWNLOAD_DIR}/api-explorer-tools-${VER}.zip ]; then
    wget --no-check-certificate ${APIX_RELEASE_URL}/api-explorer-tools-${VER}.zip --output-document ${DOWNLOAD_DIR}/api-explorer-tools-${VER}.zip
    rm -rf ${TOOLS_DIR}  # if we downloaded new tools, wipe the old ones
fi

# only stage the tools once
if [ -d "${TOOLS_DIR}" ]; then
    echo "Already staged tools"
else
    echo "Staging tools"
    mkdir -p ${TOOLS_DIR}
    pushd ${TOOLS_DIR}
    unzip ${DOWNLOAD_DIR}/api-explorer-tools-${VER}.zip
    popd
fi

# Clean the staging directory if it already exists
rm -rf ${OUTPUT_DIR}/*
mkdir -p ${OUTPUT_DIR}/docs
mkdir -p ${OUTPUT_DIR}/api/system/help

pushd ${OUTPUT_DIR}

echo "Extracting APIX distribution"
unzip ${DOWNLOAD_DIR}/api-explorer-dist-${VER}.zip

# remove stock local.json as we do not use it and we move to a different location
rm local.json config.js

echo "Staging doc files"
cp -Rvf ${SCRIPT_DIR}/additional-content/* .

echo "staging local.json as ${OUTPUT_DIR}/api/system/help/localjson"
cp -vf ${SCRIPT_DIR}/override-content/local.json ${OUTPUT_DIR}/api/system/help/localjson

echo "Overwriting stock config with local config"
cp -vf ${SCRIPT_DIR}/override-content/config.js .

cp -vf ${SCRIPT_DIR}/override-content/favicon.ico .

echo "staging swagger files"
cp -vf ${SCRIPT_DIR}/swagger/* ${OUTPUT_DIR}/api/system/help/

# the commented lines below run a tool which generates the local.json file 
# from a given set of swagger files.  this is not used currently and instead
# we are using a statically defined local.json (localjson) that has hard coded
# links in it.

#echo "Staging local API content"
#python ${TOOLS_DIR}/apixlocal/apixlocal.py \
# stage \
# --server=${APIX_SERVER} \
# --html_root_dir=${OUTPUT_DIR} \
# --abbreviate_description \
# --generate_overview_html \
# --output_file=${OUTPUT_DIR}/api/system/help/localjson  \
# --product_name="VMware Workspace ONE UEM;9.3" \
# --api_version="9.3" \
# --swagger_glob=${SCRIPT_DIR}/new-swagger/* \
# --swagger_output_dir=${OUTPUT_DIR}/local/swagger \
# --file_name_to_api_uid_properties_file_path=${SCRIPT_DIR}/api-uid-mappings.properties



# inline replace title on the API Explorer index.html file to reflect our product branding
sed -i 's/API Explorer/Workspace ONE UEM API Explorer/' ${OUTPUT_DIR}/index.html

popd
