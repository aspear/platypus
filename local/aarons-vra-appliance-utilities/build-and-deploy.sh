#!/bin/bash

set -x  # fail the script if any command fails

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

echo "get a snapshot of the current swagger docs from the running services on this appliance."
source ${SCRIPT_DIR}/get-vra-docs.sh

echo "build the APIX site image locally"
source ${SCRIPT_DIR}/build.sh

echo "find/replacing hostname in config.js file for vRA SSO support"
HOSTNAME=`hostname -f`
VRA_SSO_ENDPOINT="https://${HOSTNAME}/identity/api/tokens";
python ${SCRIPT_DIR}/tools/apixlocal/replace_variable.py \
 --verbose \
 --variable_name=window.config.authApiEndPoint \
 --variable_value=${VRA_SSO_ENDPOINT} \
 ./config.js

echo "deploy the built local site on this appliance"
source ${SCRIPT_DIR}/deploy-apix.sh
