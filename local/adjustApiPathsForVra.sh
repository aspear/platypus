#!/bin/bash

# This utility adjusts the paths that are used in the stock API Explorer so that
# they will work with the component-registry services location and configuration
# which has a web root that is not the same as the location of the files.
#
# Author: aspear@vmware.com

FILE=$1

if [ "" == "$1" ]; then
echo "provide a file path as an arg"
exit 1;
fi

adjustPathsInFile() {
    sed -i s@\"scripts/@\"../api/docs/scripts/@g $1
    sed -i s@\"fonts/@\"../api/docs/fonts/@g $1
    sed -i s@\"local/@\"../api/docs/local/@g $1
    sed -i s@\"styles/@\"../api/docs/styles/@g $1
    sed -i s@\"images/@\"../api/docs/images/@g $1
    sed -i s@\"favicon.ico@\"../api/docs/favicon.ico@g $1
    sed -i s@\'swagger-console.html@\'../api/docs/swagger-console.html@g $1
    sed -i s@\"about.html\"@\"../api/docs/about.html\"@g $1
}
echo "adjustApiPathsForVra in $FILE"
adjustPathsInFile $FILE
