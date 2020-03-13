#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [ "$1" != "" ]; then
SPEC_HOST=$1
else
SPEC_HOST=console-stg.cloud.vmware.com/csp/gateway
fi

echo "Downloading Swagger files from host $SPEC_HOST"

VALUES="https://${SPEC_HOST}/am/api/v2/api-docs?group=docs;iam
https://${SPEC_HOST}/billing/api/v2/api-docs?group=docs;billing
https://${SPEC_HOST}/slc/api/v2/api-docs?group=docs;slc
https://${SPEC_HOST}/iam/vmwid/api/v2/api-docs?group=docs;vmwid
https://${SPEC_HOST}/commerce/api/v2/api-docs?group=docs;commerce
https://${SPEC_HOST}/po/api/v1/swagger-ui.html/swagger.json/;po
https://${SPEC_HOST}/es/api/v1/swagger-ui.html/swagger.json/;es
https://${SPEC_HOST}/os/api/swagger-ui.html;os
https://${SPEC_HOST}/um/api/v2/api-docs?group=docs;um
https://${SPEC_HOST}/ff-service/api/v2/api-docs?group=docs;ff
";

OUTPUT_DIR=${SCRIPT_DIR}/swagger

rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

pushd ${OUTPUT_DIR}

for VALUE in $VALUES; do
SERVER_URL=${VALUE%%;*} # will drop part of string from first occur of `SubStr` to the end
NAME=${VALUE#*;}  # will drop begin of string upto first occur of `SubStr`
  echo "NAME=${NAME} SERVER_URL=${SERVER_URL}"
  wget --no-check-certificate -q -O api_csp_${NAME}.json ${SERVER_URL}
done

echo "Done downloading from host $SPEC_HOST to dir $OUTPUT_DIR."

popd
