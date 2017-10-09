#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

OUTPUT_DIR=${SCRIPT_DIR}/swagger
rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}
pushd ${OUTPUT_DIR}

# 5/15/2017 NOTE: these are currently broken, so removed. 
# https://vcac-be.eng.vmware.com/healthbroker-proxy-server/api/docs/swagger.json;healthbroker-proxy-server
# https://vcac-be.eng.vmware.com/config-management-service/api/docs/swagger.json;config-management-service

# 8/22/2017 the following are current reporting 404's, have the URLs changed or?
# api-vra-endpoint-configuration-service.json
#api-vra-iaas-proxy-provider.json
#api-vra-ipam-service.json
#api-vra-management-service.json
#api-vra-network-service.json
#api-vra-placement-service.json


#VRA_HOST=https://vcac-be.eng.vmware.com
VRA_HOST=https://localhost
VALUES="
${VRA_HOST}/advanced-designer-service/api/docs/swagger.json;advanced-designer-service
${VRA_HOST}/approval-service/api/docs/swagger.json;approval-service
${VRA_HOST}/branding-service/api/docs/swagger.json;branding-service
${VRA_HOST}/catalog-service/api/docs/swagger.json;catalog-service
${VRA_HOST}/component-registry/api/docs/swagger.json;component-registry
${VRA_HOST}/composition-service/api/docs/swagger.json;composition-service
${VRA_HOST}/container-service/api/docs/swagger.json;container-service
${VRA_HOST}/content-management-service/api/docs/swagger.json;content-management
${VRA_HOST}/endpoint-configuration-service/api/docs/swagger.json;endpoint-configuration-service
${VRA_HOST}/event-broker-service/api/docs/swagger.json;event-broker-service
${VRA_HOST}/forms-service/api/docs/swagger.json;forms-service
${VRA_HOST}/iaas-proxy-provider/api/docs/swagger.json;iaas-proxy-provider
${VRA_HOST}/identity/api/docs/swagger.json;identity
${VRA_HOST}/ipam-service/api/docs/swagger.json;ipam-service
${VRA_HOST}/component-registry/api/docs/licensing/swagger.json;licensing-service
${VRA_HOST}/management-service/api/docs/swagger.json;management-service
${VRA_HOST}/network-service/api/docs/swagger.json;network-service
${VRA_HOST}/notification-service/api/docs/swagger.json;notification-service
${VRA_HOST}/o11n-gateway-service/api/docs/swagger.json;o11n-gateway-service
${VRA_HOST}/placement-service/api/docs/swagger.json;placement-service
${VRA_HOST}/component-registry/api/docs/extensibility/swagger.json;plugin-service
${VRA_HOST}/portal-service/api/docs/swagger.json;portal-service
${VRA_HOST}/properties-service/api/docs/swagger.json;properties-service
${VRA_HOST}/reservation-service/api/docs/swagger.json;reservation-service
${VRA_HOST}/software-service/api/docs/swagger.json;software-service
${VRA_HOST}:443/vco/api/docs/swagger.json;vco
${VRA_HOST}/workitem-service/api/docs/swagger.json;workitem-service
";


for VALUE in $VALUES; do
SERVER_URL=${VALUE%%;*} # will drop part of string from first occur of `SubStr` to the end
NAME=${VALUE#*;}  # will drop begin of string upto first occur of `SubStr`
  echo "NAME=${NAME} SERVER_URL=${SERVER_URL}"
  # i have no idea why, but it seems that wget does not work for SSL connections to local services...
  #echo "wget --no-check-certificate -q -O api-vra-${NAME}.json ${SERVER_URL}"
  curl -s -w "%{http_code}\n" --insecure -o api-vra-${NAME}.json ${SERVER_URL}
done

popd
