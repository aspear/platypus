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
export VER="1.1.3"
export MILESTONE=""

# -----------------------------------------------------------------------------
APIX_RELEASE_URL=https://github.com/vmware/api-explorer/releases/download/${VER}${MILESTONE}

OUTPUT_DIR=${BUILD_DIR}/staging
OUTPUT_DIR_VA=${BUILD_DIR}/staging-va
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
rm -rf ${OUTPUT_DIR_VA}/*
mkdir -p ${OUTPUT_DIR_VA}

rm -rf ${OUTPUT_DIR}/*
mkdir -p ${OUTPUT_DIR}/local/swagger

pushd ${OUTPUT_DIR}

echo "Extracting APIX distribution"
unzip ${DOWNLOAD_DIR}/api-explorer-dist-${VER}.zip

echo "Overwriting stock config with local config"
cp -f ${SCRIPT_DIR}/config.js .

# run the tool to stage the swagger json files from the 
# ${SCRIPT_DIR}/swagger directory to the local/swagger
# directory, abbreviating the descriptions and then also taking the 
# markdown description from the swagger and generating overview HTML
# next to the json files.  When it does this it generates an "overview"
# resource in the local.json file that has all of the configuration in it
echo "staging local API content"
python ${TOOLS_DIR}/apixlocal/apixlocal.py \
 stage \
 --server=${APIX_SERVER} \
 --html_root_dir=${OUTPUT_DIR} \
 --output_file=${OUTPUT_DIR}/local.json  \
 --abbreviate_description \
 --generate_overview_html \
 --product_name="vRealize Automation;7.5" \
 --api_version="7.5" \
 --swagger_glob ${SCRIPT_DIR}/swagger/*.json \
 --swagger_output_dir=${OUTPUT_DIR}/local/swagger \
 --file_name_to_api_uid_properties_file_path=${SCRIPT_DIR}/api-uid-mappings.properties

# inline replace title on the API Explorer index.html file to reflect our product branding
sed -i 's/API Explorer/VMware vRealize Automation API Explorer/' ${OUTPUT_DIR}/index.html

# now create a war file that is simply a wrapper on the image 
#WAR_FILE_NAME=api-explorer-vra.war
#mkdir -p ${OUTPUT_DIR}/WEB-INF
#cat > ${OUTPUT_DIR}/WEB-INF/web.xml <<- "EOF"
#<web-app version="3.0" xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd">
#<display-name>VMware vRealize Automation API Explorer</display-name>
#<welcome-file-list><welcome-file>index.html</welcome-file></welcome-file-list>
#</web-app>
#EOF
#
#zip -r ${OUTPUT_DIR}/${WAR_FILE_NAME} *

echo "Creating VA staging dir"
cp -R ${OUTPUT_DIR}/* ${OUTPUT_DIR_VA}
find ${OUTPUT_DIR_VA} -type f -exec  ${SCRIPT_DIR}/adjustApiPathsForVra.sh {} \;

popd
