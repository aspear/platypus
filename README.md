## VMware API Explorer POC

This POC was derived from the open source [Project Platypus](http://github.com/vmware/platypus/ which is a Docker container
that is a host for API documentation that embeds [VMware's API Explorer component](http://github.com/vmware/api-explorer/).  
The API Explorer is a simple component with no server side dependencies that can be embedded in any web container such as the NGINX server running in a Docker container in this case. 

#### Now to build and run
Builds are two step.  
1) The first downloads the necessary tools from the API Explorer project,
creates a web root by extracting the built API explorer, and then stages local Swagger APIs
into that web image also creating necessary API metadata:

`cd local`
`./build.sh`

2) The second builds the docker container with nginx serving the web image:
`docker build -t pickaname .`

This command runs the Docker container in daemon mode (in the background) on the local host port 8080:
`docker run -d --name pickaname -p 8080:80 pickaname`

Please direct questions to Aaron Spear, aspear@vmware.com

