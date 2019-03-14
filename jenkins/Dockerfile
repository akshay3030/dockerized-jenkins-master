FROM jenkins/jenkins:2.164.1-alpine
#FROM jenkins/jenkins:2.164.1
USER root
#RUN curl -Sslk https://download.docker.com/linux/static/stable/x86_64/docker-18.06.1-ce.tgz -o docker-18.06.1-ce.tgz
#RUN tar -zxvf docker-18.06.1-ce.tgz -C /usr/local/bin

RUN apk add --update py-pip && pip install --upgrade pip && pip install awscli

#RUN apt-get install python-pip && pip install awscli --upgrade --user
RUN apk add jq

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV DOCKER_CONFIG="/var/jenkins_home"

COPY docker /usr/local/bin/docker

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/init.groovy
 
COPY plugins.list /usr/share/jenkins/ref/plugins.list

#COPY config-saml.xml /usr/share/jenkins/ref/config.xml this won't work from here,
#use init.groovy to configure it --> https://github.com/codeontap/docker-jenkins-master/blob/fbde86bb1b328152efa4f1012759610fe21bc0d3/scripts/init/configure-initial-user.groovy or https://github.com/jenkinsci/saml-plugin/blob/master/src/main/java/org/jenkinsci/plugins/saml/SamlSecurityRealm.java


RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.list

RUN git config --global http.sslVerify false

