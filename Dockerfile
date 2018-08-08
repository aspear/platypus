# Docker build file for VMware vcode-dev-center-app derived web based devcenter
# this version assumes that the build of the web server HTML/image has been done in a script outside
# of this dockerfile already (local/build.sh).  This script creates the ./local/staging directory which is the
# ready to go image.  this could be embedded in any other web container...

FROM alpine:3.3

MAINTAINER Aaron Spear

# need nginx web server.  
RUN apk add --update nginx 

WORKDIR /usr/share/nginx/html/

COPY ./local/staging /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/nginx.conf
COPY "runner.sh" /usr/share/nginx/html/
ADD ./local/favicon.ico /usr/share/nginx/html/

EXPOSE 80
ENTRYPOINT ["/usr/share/nginx/html/runner.sh"]
