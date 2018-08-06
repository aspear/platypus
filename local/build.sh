#!/bin/bash

###############################################################################
# Copyright VMware, Inc. 2017. All Rights Reserved.
# VMware internal, not open source.  (yet)
#
# This script builds an web server image in the file system of the VMware {code}
# "Devcenter App" https://gitlab.eng.vmware.com/gtix-tools/vcode-dev-center-app
# 
# Read https://gitlab.eng.vmware.com/gtix-tools/vcode-dev-center-app/blob/master/INTEGRATION.md'
# for instructions on integration.
#
###############################################################################

set -x  # fail the script if any command fails
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

# -----------------------------------------------------------------------------
# VARIABLES YOU CAN SET

# you can supply an overridden build directory via BUILD_DIR variable if you 
# wish.  If not provided, all output is created in this (the script) directory.
BUILD_DIR=${BUILD_DIR:-${SCRIPT_DIR}}

# the VER variable is the one place to change the particular release of API 
# explorer.  See https://build-artifactory.eng.vmware.com/artifactory/npm/%40vmw/vcode-dev-center-app/-/@vmw
# for valid values
export VER="0.1.0"

# -----------------------------------------------------------------------------
ARTIFACTORY_URL=https://build-artifactory.eng.vmware.com/artifactory/npm/%40vmw/vcode-dev-center-app/-/@vmw
DEV_CENTER_APP_FILE=vcode-dev-center-app-${VER}.tgz

OUTPUT_DIR=${BUILD_DIR}/staging
TOOLS_DIR=${BUILD_DIR}/tools
DOWNLOAD_DIR=${BUILD_DIR}/download
PUBLISH_DIR=${BUILD_DIR}/publish

mkdir -p ${DOWNLOAD_DIR}

if [ ! -f ${DOWNLOAD_DIR}/${DEV_CENTER_APP_FILE} ]; then
    echo "Downloading archives of the distribution to ${DOWNLOAD_DIR}/${DEV_CENTER_APP_FILE}"
    wget --no-check-certificate ${ARTIFACTORY_URL}/${DEV_CENTER_APP_FILE} --output-document ${DOWNLOAD_DIR}/${DEV_CENTER_APP_FILE}
    pushd ${DOWNLOAD_DIR}
    tar xfz ${DEV_CENTER_APP_FILE}  #this creates ${DOWNLOAD_DIR}/package/dist and ${DOWNLOAD_DIR}/package/tools
    rm -rf ${TOOLS_DIR}  # if we downloaded new tools, wipe the old ones
else
    echo "Using cached copy of ${DOWNLOAD_DIR}/${DEV_CENTER_APP_FILE}"
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
pushd ${OUTPUT_DIR}

echo "Extracting dev-center distribution"
cp -R ${DOWNLOAD_DIR}/package/dist/* .

echo "Cleaning up unneeded files in distribution"
rm -fv ./assets/apix-swagger.json
rm -fv ./assets/dev-center-overview.html
rm -fv ./assets/sample-exchange-swagger.json
#rm -fv ./assets/swagger-auth.json
#rm -fv ./assets/swagger-complete.json
rm -fv ./assets/vra-auth.json
#rm -fv ./assets/vra-config.json
rm -rfv ./local

echo "Removing stock configuration files (will be overwritten, but to catch errors we remove them explicitly)"
rm -fv ./assets/dev-center-config.json
rm -fv ./assets/apis.json

echo "Staging product specific dev-center-config.json as well as apis.json"
cp -fv ${SCRIPT_DIR}/dev-center-config.json ./assets
cp -fv ${SCRIPT_DIR}/apis.json ./assets
cp -fv ${SCRIPT_DIR}/favicon.ico ./    # copy VMware standard icon.  Replace with your products if there is one.


# The below commented code is an attempt to create a static war file wrapper for the content
#WAR_OUTPUT_DIR=${BUILD_DIR}/staging-war
#rm -rf ${WAR_OUTPUT_DIR}/*
#mkdir -p ${WAR_OUTPUT_DIR}
#WAR_FILE_NAME=dev-center.war
#pushd ${WAR_OUTPUT_DIR}
#echo "Staging war metadata"
#cp -Rv ${SCRIPT_DIR}/war-template/* ${WAR_OUTPUT_DIR}
#mkdir -p ${WAR_OUTPUT_DIR}/web
#cp -Rv ${OUTPUT_DIR}/* ${WAR_OUTPUT_DIR}/web
#echo "Creating war file ${PUBLISH_DIR}/${WAR_FILE_NAME}"
#zip -r ${PUBLISH_DIR}/${WAR_FILE_NAME} *
#popd
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
echo "DONE!"
