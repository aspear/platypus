# Docker build file for VMware Platypus API explorer container build
FROM alpine:3.3

MAINTAINER Roman Tarnavski, Aaron Spear

# need nginx web server.  
RUN apk add --update nginx 

WORKDIR /usr/share/nginx/html/

# this hacked version assumes that the build of the web server HTML/image has been done in a script outside
# of this dockerfile already (vra/build-vra.sh).  This script creates the ./vra/staging directory which is the 
# ready to go image.  this could be embedded in any other web container...

# (note that the normal Platypus project build dynamically assembles this image by downloading the API Explorer
# component, unzipping it and then staging swagger.json files during the Docker build)
COPY ./local/staging /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/nginx.conf
COPY "runner.sh" /usr/share/nginx/html/
ADD ./local/favicon.ico /usr/share/nginx/html/

EXPOSE 80
ENTRYPOINT ["/usr/share/nginx/html/runner.sh"]
