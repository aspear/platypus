#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

# 5/15/2017 NOTE: these are currently broken, so removed. 
# https://vcac-be.eng.vmware.com/healthbroker-proxy-server/api/docs/swagger.json;healthbroker-proxy-server
# https://vcac-be.eng.vmware.com/config-management-service/api/docs/swagger.json;config-management-service

VALUES="
https://vcac-be.eng.vmware.com/advanced-designer-service/api/docs/swagger.json;advanced-designer-service
https://vcac-be.eng.vmware.com/approval-service/api/docs/swagger.json;approval-service
https://vcac-be.eng.vmware.com/branding-service/api/docs/swagger.json;branding-service
https://vcac-be.eng.vmware.com/catalog-service/api/docs/swagger.json;catalog-service
https://vcac-be.eng.vmware.com/component-registry/api/docs/swagger.json;component-registry
https://vcac-be.eng.vmware.com/composition-service/api/docs/swagger.json;composition-service
https://vcac-be.eng.vmware.com/container-service/api/docs/swagger.json;container-service
https://vcac-be.eng.vmware.com/content-management-service/api/docs/swagger.json;content-management
https://vcac-be.eng.vmware.com/endpoint-configuration-service/api/docs/swagger.json;endpoint-configuration-service
https://vcac-be.eng.vmware.com/event-broker-service/api/docs/swagger.json;event-broker-service
https://vcac-be.eng.vmware.com/forms-service/api/docs/swagger.json;forms-service
https://vcac-be.eng.vmware.com/iaas-proxy-provider/api/docs/swagger.json;iaas-proxy-provider
https://vcac-be.eng.vmware.com/identity/api/docs/swagger.json;identity
https://vcac-be.eng.vmware.com/ipam-service/api/docs/swagger.json;ipam-service
https://vcac-be.eng.vmware.com/component-registry/api/docs/licensing/swagger.json;licensing-service
https://vcac-be.eng.vmware.com/management-service/api/docs/swagger.json;management-service
https://vcac-be.eng.vmware.com/network-service/api/docs/swagger.json;network-service
https://vcac-be.eng.vmware.com/notification-service/api/docs/swagger.json;notification-service
https://vcac-be.eng.vmware.com/o11n-gateway-service/api/docs/swagger.json;o11n-gateway-service
https://vcac-be.eng.vmware.com/placement-service/api/docs/swagger.json;placement-service
https://vcac-be.eng.vmware.com/component-registry/api/docs/extensibility/swagger.json;plugin-service
https://vcac-be.eng.vmware.com/portal-service/api/docs/swagger.json;portal-service
https://vcac-be.eng.vmware.com/properties-service/api/docs/swagger.json;properties-service
https://vcac-be.eng.vmware.com/reservation-service/api/docs/swagger.json;reservation-service
https://vcac-be.eng.vmware.com/software-service/api/docs/swagger.json;software-service
https://vcac-be.eng.vmware.com:443/vco/api/docs/swagger.json;vco
https://vcac-be.eng.vmware.com/workitem-service/api/docs/swagger.json;workitem-service
";

#for VALUE in $VALUES; do
#SERVER_URL=${VALUE%%;*} # will drop part of string from first occur of `SubStr` to the end
#NAME=${VALUE#*;}  # will drop begin of string upto first occur of `SubStr`
#echo "SERVER=${SERVER_URL} NAME=${NAME}"
#done

OUTPUT_DIR=${SCRIPT_DIR}/swagger-vra

rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

pushd ${OUTPUT_DIR}

for VALUE in $VALUES; do
SERVER_URL=${VALUE%%;*} # will drop part of string from first occur of `SubStr` to the end
NAME=${VALUE#*;}  # will drop begin of string upto first occur of `SubStr`
  echo "NAME=${NAME} SERVER_URL=${SERVER_URL}"
  wget --no-check-certificate -q -O api-vra-${NAME}.json ${SERVER_URL}
done

popd

#zip -r photon-controller-api-docs-swagger12.zip api-docs api-docsapis
