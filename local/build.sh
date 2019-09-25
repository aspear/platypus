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

APIX_SERVER=https://apigw.vmware.com/v1/m4/api/dcr/rest/apix/apis

# -----------------------------------------------------------------------------
# VARIABLES YOU CAN SET

# you can supply an overridden build directory via BUILD_DIR variable if you 
# wish.  If not provided, all output is created in this (the script) directory.
BUILD_DIR=${BUILD_DIR:-${SCRIPT_DIR}}

# if your dev-center is not in the server root, you must supply is not in the root (likely)
# you must supply this path here by setting DEV_CENTER_ROOT_PATH.  Note that it must start
# and end with a / char, or be a single / in the case that it is in the root.
DEV_CENTER_ROOT_PATH=${DEV_CENTER_ROOT_PATH:-"/"}

# the VER variable is the one place to change the particular release of API 
# explorer.  See https://build-artifactory.eng.vmware.com/artifactory/npm/%40vmw/vcode-dev-center-app/-/@vmw
# for valid values
export VER="7.0.1"

# -----------------------------------------------------------------------------
ARTIFACTORY_URL=https://build-artifactory.eng.vmware.com/artifactory/npm/%40vmw/vcode-dev-center-app/-/@vmw
DEV_CENTER_APP_FILE=vcode-dev-center-app-${VER}.tgz

OUTPUT_DIR=${BUILD_DIR}/staging
OUTPUT_DIR_VA=${BUILD_DIR}/staging-va
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
mkdir -p ${OUTPUT_DIR}/local/swagger
pushd ${OUTPUT_DIR}

echo "Staging dev-center distribution"
cp -R ${DOWNLOAD_DIR}/package/dist/{.[^.],}* .

echo "Cleaning up unneeded files in distribution"
rm -fv ./assets/apix-swagger.json
rm -fv ./assets/dev-center-overview.html
rm -fv ./assets/sample-exchange-swagger.json
#rm -fv ./assets/swagger-auth.json
rm -fv ./assets/swagger-complete.json
rm -fv ./assets/vra-auth.json
rm -fv ./assets/vra-config.json
rm -rfv ./local

echo "Removing stock configuration files (will be overwritten, but to catch errors we remove them explicitly)"
rm -fv ./assets/dev-center-config.json
rm -fv ./assets/apis.json

echo "Staging product specific dev-center-config.json as well as apis.json"
cp -fv ${SCRIPT_DIR}/dev-center-config.json ./assets
cp -fv ${SCRIPT_DIR}/favicon.ico ./    # copy VMware standard icon.  Replace with your products if there is one.

echo "Generating apis.json"
# run the tool to stage the swagger json files from the 
# ${SCRIPT_DIR}/swagger directory to the local/swagger
# directory, abbreviating the descriptions and then also taking the 
# markdown description from the swagger and generating overview HTML
# next to the json files.  When it does this it generates an "overview"
# resource in the local.json file that has all of the configuration in it
python ${TOOLS_DIR}/apixlocal.py \
 stage \
 --server=${APIX_SERVER} \
 --html_root_dir=${OUTPUT_DIR} \
 --output_file=${OUTPUT_DIR}/apis.json  \
 --product_name="NSX-T Data Center;2.1.0" \
 --swagger_url="name=NSX-T Data Center REST API,description=NSX-T API FROM vdc-download,version=2.1.0,url=https://vdc-download.vmware.com/vmwb-repository/dcr-public/d78d97e5-a2b0-45a4-97cd-c5b73fdc8b95/85fb0c30-3a55-477f-b70d-4386ed40bf15/nsx_api.json,product=NSX-T Data Center"

echo "Using DEV_CENTER_ROOT_PATH variable to set base path in generated files to \"${DEV_CENTER_ROOT_PATH}\""
sed -i "s|<base href=\\\"/\\\">|<base href=\\\"${DEV_CENTER_ROOT_PATH}\\\">|g" ./index.html
sed -i "s|VMware {code} Developer Center App|AirWatch Developer Center|g" ./index.html
sed -i "s|/dev-center-app/|/${DEV_CENTER_ROOT_PATH}/|g" ./.htaccess
sed -i "s|/dev-center-app/|/${DEV_CENTER_ROOT_PATH}/|g" ./server.rewrites


echo "Publishing output zip file ${PUBLISH_DIR}/dev-center.zip"
mkdir -p ${PUBLISH_DIR}
zip -r ${PUBLISH_DIR}/dev-center.zip {.[^.],}*

popd
echo "DONE!"
