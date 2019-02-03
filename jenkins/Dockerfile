FROM laglinaro/jenkinsdocker:master
USER root

RUN apt-get update -y
RUN apt-get install python-pip -y && pip install awscli --upgrade --user

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"
ENV DOCKER_CONFIG="/var/jenkins_home"

RUN curl -sSLk -o /tmp/docker.tgz https://download.docker.com/linux/static/stable/aarch64/$(curl -sSkL https://download.docker.com/linux/static/stable/aarch64/|grep '^ *<a'|grep docker|awk -F '"' '{print $2}'|sort -nr|head -1) \
  && cd /tmp \
  && tar zxvf docker.tgz \
  && mv docker/docker /usr/local/bin \
  && rm -rfv docker docker.tgz

COPY init.groovy /usr/share/jenkins/ref/init.groovy.d/init.groovy
 
COPY plugins.list /usr/share/jenkins/ref/plugins.list

#COPY config-saml.xml /usr/share/jenkins/ref/config.xml this won't work from here,
#use init.groovy to configure it --> https://github.com/codeontap/docker-jenkins-master/blob/fbde86bb1b328152efa4f1012759610fe21bc0d3/scripts/init/configure-initial-user.groovy or https://github.com/jenkinsci/saml-plugin/blob/master/src/main/java/org/jenkinsci/plugins/saml/SamlSecurityRealm.java


RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.list

RUN git config --global http.sslVerify false