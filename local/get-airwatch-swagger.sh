#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"

if [ "$1" != "" ]; then
SWAGGER_HOST=$1
else
SWAGGER_HOST=cc92.ssdevrd.com
fi

echo "Downloading Swagger files from host $SWAGGER_HOST"

VALUES="
https://${SWAGGER_HOST}/api/mam/swagger/docs/1;Mam_API_V1
https://${SWAGGER_HOST}/api/mam/swagger/docs/2;Mam_API_V2
https://${SWAGGER_HOST}/api/mcm/swagger/docs/1;Mcm_API_V1
https://${SWAGGER_HOST}/api/mdm/swagger/docs/1;Mdm_API_V1
https://${SWAGGER_HOST}/api/mdm/swagger/docs/2;Mdm_API_V1
https://${SWAGGER_HOST}/api/mem/swagger/docs/1;Mem_API_V1
https://${SWAGGER_HOST}/api/system/swagger/docs/1;System_API_V1
https://${SWAGGER_HOST}/api/system/swagger/docs/2;System_API_V2
";

OUTPUT_DIR=${SCRIPT_DIR}/swagger

rm -rf ${OUTPUT_DIR}
mkdir -p ${OUTPUT_DIR}

pushd ${OUTPUT_DIR}

for VALUE in $VALUES; do
SERVER_URL=${VALUE%%;*} # will drop part of string from first occur of `SubStr` to the end
NAME=${VALUE#*;}  # will drop begin of string upto first occur of `SubStr`
  echo "NAME=${NAME} SERVER_URL=${SERVER_URL}"
  wget --no-check-certificate -q -O ${NAME}.json ${SERVER_URL}
done

echo "Done downloading from host $SWAGGER_HOST to dir $OUTPUT_DIR."

popd
