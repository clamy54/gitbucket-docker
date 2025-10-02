FROM ubuntu:24.04
LABEL org.opencontainers.image.authors="root@be-root.com"
ENV container=docker

# Create required directories
RUN mkdir /migration
RUN mkdir /gitbucket && mkdir /opt/gitbucket

# Install dependencies
RUN apt update && apt -y upgrade && apt -y install openjdk-17-jre-headless sed grep curl

# Download GitBucket and H2 jars
ADD https://github.com/gitbucket/gitbucket/releases/download/4.44.0/gitbucket.war /opt/gitbucket/gitbucket.war
ADD https://repo1.maven.org/maven2/com/h2database/h2/1.4.199/h2-1.4.199.jar /migration/h2-1.4.199.jar
ADD https://repo1.maven.org/maven2/com/h2database/h2/2.3.232/h2-2.3.232.jar /migration/h2-2.3.232.jar 

# Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
ENV PATH=$JAVA_HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Link GitBucket data directory
RUN ln -s /gitbucket /root/.gitbucket

# Copy custom run.sh script to container root and make it executable
COPY files/run.sh /run.sh
RUN chmod +x /run.sh

# Volume and ports
VOLUME ["/gitbucket"]
EXPOSE 8080
EXPOSE 29418

# Use bash as shell
SHELL ["/bin/bash", "-c"]

# Entrypoint
ENTRYPOINT ["/run.sh"]
