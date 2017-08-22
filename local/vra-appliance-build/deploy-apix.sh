#!/bin/bash

# Copyright 2017 VMware Inc, All rights reserved.
# This script takes a war file that is a build of API
# Explorer configured for vRA localed in /tmp and creates a web app
# using the vRA tomcat web container located at /apix.  There is nothing
# special here but moving files around and changing permissions and such
# so that tomcat is happy and will autodeploy it

set -x

SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
OUTPUT_DIR=${SCRIPT_DIR}/staging

TIMESTAMP=`date +%Y%m%d_%H%M%S`

echo "undeploying current apix by unlinking"
cd /etc/vcac/webapps
unlink apix

echo "backing up current apix"
mkdir -p ~/apix-save
mv -v /usr/lib/vcac/server/webapps/apix ~/apix-save/apix-save-${TIMESTAMP}

echo "extracting new apix war"
rm -rf /tmp/apix
mkdir /tmp/apix

cd /tmp/apix
unzip ${OUTPUT_DIR}/api-explorer*.war

echo "fixing up file and directory permissions"
chmod -R og+r *
find . -type d -exec chmod og+rx {} \;


echo "moving new apix"
mv -v /tmp/apix /usr/lib/vcac/server/webapps

chmod og+rx /usr/lib/vcac/server/webapps/apix

echo "creating symlink for new webapp"
cd /etc/vcac/webapps
ln -s /usr/lib/vcac/server/webapps/apix

