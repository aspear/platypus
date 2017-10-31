## This is a VMware internal fork of the Platypus project https://github.com/vmware/platypus ##
The idea here is a local test bed for creation of an API Explorer

#### Build and run

`cd local`

This step downloads the release of API Explorer from Github, inserts the local
swagger specs, and fixes up configuration and filtering in the API Explorer widget
`build.sh`


Change back into the root directory
`cd ..`

Run docker to built a web server container for the API Explorer
`docker build -t platypus .`

Run the docker container
`docker run -p 80:80 platypus`

