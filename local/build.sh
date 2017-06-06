#!/bin/bash

set -x

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

OUTPUT_DIR=${SCRIPT_DIR}/staging

TOOLS_DIR=${SCRIPT_DIR}/tools

APIX_SERVER=https://vdc-repo.vmware.com

export VER="0.0.21"
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

echo "overwriting config with vsphere local config"
cp -f ${SCRIPT_DIR}/config.js .

echo "Mirroring API content from ${APIX_SERVER}"
python ${TOOLS_DIR}/apixlocal/apixlocal.py \
 --server=${APIX_SERVER} \
 --html_root_dir=${OUTPUT_DIR} \
 --output_file=${OUTPUT_DIR}/local.json  \
 --mirror_output_dir=${OUTPUT_DIR}/local/mirror \
 --mirror_api=api_vsphere \
 --mirror_api=api_vcenter_infrastructure \
 --mirror_api=api_content \
 --mirror_api=api_vcenter_server_appliance_infrastructure \
 --mirror_api=api_vapi_infrastructure \
 --mirror_api=api_cis_management \
 --mirror_api=api_vcenter_server_appliance_management \
 --mirror_api=api_cis_infrastructure \
 --mirror_api=api_vcenter_management \
 --mirror_api=api_vapi_management \
 --mirror_api=api_vsphere_automation_java \
 --mirror_api=api_vsphere_automation_dotnet \
 --mirror_api=api_vsphere_automation_python \
 --mirror_api=api_vsphere_automation_ruby \
 --mirror_api=api_vsphere_automation_perl \
 --mirror_api=api_vsphere_automation_lookup_service \
 --mirror_api=api_vsphere_esx_agent_manager \
 --mirror_api=api_vcenter_sso \
 --mirror_api=api_storage_monitoring_service \
 --mirror_api=api_vsphere_guest \
 --mirror_api=api_vsphere_ha_application_monitor \
 --mirror_api=api_cim \
 --mirror_api=api_virtual_disk

popd
