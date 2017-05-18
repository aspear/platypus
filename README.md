## VMware API Explorer POC

This POC was derived from the open source [Project Platypus](http://github.com/vmware/platypus/ which is a Docker container
that is a host for API documentation that embeds [VMware's API Explorer component](http://github.com/vmware/api-explorer/). 

#### Build and run

Builds are two step.  The first downloads the necessary tools from the API Explorer project,
creates a web root by extracting the built API explorer, and then stages local Swagger APIs
into that web image also creating necessary API metadata:
and then creates:

`cd local`
`./build.sh`

The second builds the docker container host for the image:
`docker build -t platypus .`

This command runs the Docker container in daemon mode (in the background) on the local host port 8080:
`docker run -d --name platypus -p 8080:80 platypus`

Please direct questions to Aaron Spear, aspear@vmware.com

