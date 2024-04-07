# Pull base image 
From tomcat:8-jre8 

# Maintainer 
MAINTAINER "sahanasonu272" 
COPY ./webapp.war /usr/local/tomcat/webapps
