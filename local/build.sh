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
export VER="0.1.0"

# -----------------------------------------------------------------------------
ARTIFACTORY_URL=https://build-artifactory.eng.vmware.com/artifactory/npm/%40vmw/vcode-dev-center-app/-/@vmw
DEV_CENTER_APP_FILE=vcode-dev-center-app-${VER}.tgz

OUTPUT_DIR=${BUILD_DIR}/staging
TOOLS_DIR=${BUILD_DIR}/tools
DOWNLOAD_DIR=${BUILD_DIR}/download
PUBLISH_DIR=${BUILD_DIR}/publish
WAR_OUTPUT_DIR=${BUILD_DIR}/staging-war

mkdir -p ${DOWNLOAD_DIR}
mkdir -p ${PUBLISH_DIR}

# download zips of the distribution and tools if not cached locally
if [ ! -f ${DOWNLOAD_DIR}/${DEV_CENTER_APP_FILE} ]; then
    wget --no-check-certificate ${ARTIFACTORY_URL}/${DEV_CENTER_APP_FILE} --output-document ${DOWNLOAD_DIR}/${DEV_CENTER_APP_FILE}
    pushd ${DOWNLOAD_DIR}
    tar xfz ${DEV_CENTER_APP_FILE}  #this creates ${DOWNLOAD_DIR}/package/dist and ${DOWNLOAD_DIR}/package/tools
    rm -rf ${TOOLS_DIR}  # if we downloaded new tools, wipe the old ones
fi

# only stage the tools once
if [ -d "${TOOLS_DIR}" ]; then
    echo "Already staged tools"
else
    echo "Staging tools"
    mkdir -p ${TOOLS_DIR}
    pushd ${TOOLS_DIR}
    unzip ${DOWNLOAD_DIR}/package/tools/apixlocal.zip
    popd
fi

# Clean the staging directory if it already exists
rm -rf ${OUTPUT_DIR}/*
mkdir -p ${OUTPUT_DIR}

rm -rf ${WAR_OUTPUT_DIR}/*
mkdir -p ${WAR_OUTPUT_DIR}

pushd ${OUTPUT_DIR}

echo "Extracting dev-center distribution"
cp -R ${DOWNLOAD_DIR}/package/dist/* .

echo "FIXME exiting early"
exit 0

echo "Cleaning up unneeded files in distribution"
rm -fv ./assets/apix-swagger.json
rm -fv ./assets/dev-center-overview.html
rm -fv ./assets/sample-exchange-swagger.json
rm -fv ./assets/swagger-auth.json
rm -fv ./assets/swagger-complete.json
rm -fv ./assets/vra-auth.json
rm -fv ./assets/vra-config.json
rm -rfv ./local

# these are the files we will overwrite
rm -fv ./assets/dev-center-config.json
rm -fv ./assets/apis.json

echo "Overwriting stock apix-config.json with custom config"
cp -fv ${SCRIPT_DIR}/dev-center-config.json ./assets
cp -fv ${SCRIPT_DIR}/apis.json ./assets

# run the tool to stage the swagger json files from the 
# ${SCRIPT_DIR}/swagger directory to the local/swagger
# directory, abbreviating the descriptions and then also taking the 
# markdown description from the swagger and generating overview HTML
# next to the json files.  When it does this it generates an "overview"
# resource in the local.json file that has all of the configuration in it
#echo "staging local API content"
#python ${TOOLS_DIR}/apixlocal/apixlocal.py \
# stage \
# --product_name="VMware {code}" \
# --api_version="" \
# --swagger_glob ${SCRIPT_DIR}/swagger/*.json \
# --swagger_output_dir ${OUTPUT_DIR}/local/swagger \
# --html_root_dir ${OUTPUT_DIR} \
# --output_file ${OUTPUT_DIR}/local.json \
# --file_name_to_api_uid_properties_file_path=${SCRIPT_DIR}/api-uid-mappings.properties
WAR_FILE_NAME=dev-center.war
pushd ${WAR_OUTPUT_DIR}
echo "Staging war metadata"
cp -Rv ${SCRIPT_DIR}/war-template/* ${WAR_OUTPUT_DIR}
mkdir -p ${WAR_OUTPUT_DIR}/web
cp -Rv ${OUTPUT_DIR}/* ${WAR_OUTPUT_DIR}/web
echo "Creating war file ${PUBLISH_DIR}/${WAR_FILE_NAME}"
zip -r ${PUBLISH_DIR}/${WAR_FILE_NAME} *
popd

#echo "Creating war metadata"
# now create a war file that is simply a wrapper on the image 

#mkdir -p ${OUTPUT_DIR}/WEB-INF
#cat > ${OUTPUT_DIR}/WEB-INF/web.xml <<- "EOF"
#<web-app version="3.0" xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd">
#<display-name>VMware {code} Services Dev Center</display-name>
#<welcome-file-list><welcome-file>index.html</welcome-file></welcome-file-list>
#</web-app>
#EOF
#echo "Creating war file ${PUBLISH_DIR}/${WAR_FILE_NAME}"
#rm -f ${PUBLISH_DIR}/${WAR_FILE_NAME}
#zip -r ${PUBLISH_DIR}/${WAR_FILE_NAME} *

popd
