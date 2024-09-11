FROM ubuntu:24.04
LABEL org.opencontainers.image.authors="root@be-root.com"
ENV container=docker

RUN apt update && apt -y upgrade && apt -y install openjdk-11-jre-headless
RUN mkdir /gitbucket && mkdir /opt/gitbucket
ADD files/gitbucket.war /opt/gitbucket/gitbucket.war
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
ENV PATH=$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN ln -s /gitbucket /root/.gitbucket
VOLUME [/gitbucket]
EXPOSE 8080
EXPOSE 29418

SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/usr/lib/jvm/java-11-openjdk-amd64/bin/java","-jar","/opt/gitbucket/gitbucket.war"]