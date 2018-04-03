#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [ "$1" != "" ]; then
VRA_HOST=$1
else
VRA_HOST=cava-n-80-047.eng.vmware.com
fi

echo "Downloading vRA Swagger files from host $VRA_HOST"

# 5/15/2017 NOTE: these are currently broken, so removed. 
# https://${VRA_HOST}/healthbroker-proxy-server/api/docs/swagger.json;healthbroker-proxy-server
# https://${VRA_HOST}/config-management-service/api/docs/swagger.json;config-management-service

VALUES="
https://${VRA_HOST}/advanced-designer-service/api/docs/swagger.json;advanced-designer-service
https://${VRA_HOST}/approval-service/api/docs/swagger.json;approval-service
https://${VRA_HOST}/branding-service/api/docs/swagger.json;branding-service
https://${VRA_HOST}/catalog-service/api/docs/swagger.json;catalog-service
https://${VRA_HOST}/component-registry/api/docs/swagger.json;component-registry
https://${VRA_HOST}/composition-service/api/docs/swagger.json;composition-service
https://${VRA_HOST}/container-service/api/docs/swagger.json;container-service
https://${VRA_HOST}/content-management-service/api/docs/swagger.json;content-management
https://${VRA_HOST}/endpoint-configuration-service/api/docs/swagger.json;endpoint-configuration-service
https://${VRA_HOST}/event-broker-service/api/docs/swagger.json;event-broker-service
https://${VRA_HOST}/forms-service/api/docs/swagger.json;forms-service
https://${VRA_HOST}/iaas-proxy-provider/api/docs/swagger.json;iaas-proxy-provider
https://${VRA_HOST}/identity/api/docs/swagger.json;identity
https://${VRA_HOST}/ipam-service/api/docs/swagger.json;ipam-service
https://${VRA_HOST}/component-registry/api/docs/licensing/swagger.json;licensing-service
https://${VRA_HOST}/management-service/api/docs/swagger.json;management-service
https://${VRA_HOST}/network-service/api/docs/swagger.json;network-service
https://${VRA_HOST}/notification-service/api/docs/swagger.json;notification-service
https://${VRA_HOST}/o11n-gateway-service/api/docs/swagger.json;o11n-gateway-service
https://${VRA_HOST}/placement-service/api/docs/swagger.json;placement-service
https://${VRA_HOST}/component-registry/api/docs/extensibility/swagger.json;plugin-service
https://${VRA_HOST}/portal-service/api/docs/swagger.json;portal-service
https://${VRA_HOST}/properties-service/api/docs/swagger.json;properties-service
https://${VRA_HOST}/reservation-service/api/docs/swagger.json;reservation-service
https://${VRA_HOST}/software-service/api/docs/swagger.json;software-service
https://${VRA_HOST}:443/vco/api/docs/swagger.json;vco
https://${VRA_HOST}/workitem-service/api/docs/swagger.json;workitem-service
";

OUTPUT_DIR=${SCRIPT_DIR}/swagger

rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

pushd ${OUTPUT_DIR}

for VALUE in $VALUES; do
SERVER_URL=${VALUE%%;*} # will drop part of string from first occur of `SubStr` to the end
NAME=${VALUE#*;}  # will drop begin of string upto first occur of `SubStr`
  echo "NAME=${NAME} SERVER_URL=${SERVER_URL}"
  wget --no-check-certificate -q -O api-vra-${NAME}.json ${SERVER_URL}
done

echo "Done downloading from host $VRA_HOST to dir $OUTPUT_DIR."

popd
