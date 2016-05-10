FROM centos:latest
USER root

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 10.0.0.Final
ENV JB_CON wildfly-mongo.jarvis-sit.svc
ENV JBOSS_HOME /wildfly

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place

ADD standalone.xml $JBOSS_HOME/standalone/configuration
RUN cd $HOME && \
    #yum install tar java jdk zip unzip wget curl -y && \
    wget "http://downloads.jboss.org/keycloak/1.9.4.Final/keycloak-1.9.4.Final.tar.gz" && \
    mv keycloak-1.9.4.Final.tar.gz $JBOSS_HOME/keycloak-distro-overlay.tar.gz && \
    sed -i 's/jboss.bind.address.management:127.0.0.1/jboss.bind.address.management:0.0.0.0/g' /wildfly/standalone/configuration/standalone.xml && \
    cd $JBOSS_HOME && \
    tar zxvf keycloak-distro-overlay.tar.gz && \
    cd $HOME
RUN $JBOSS_HOME/bin/add-user.sh admin P@ssw0rd10 --silent
ADD mongojdbc1.2.jar $JBOSS_HOME/bin/standalone/deployments
ADD postgresql-9.4.1208.jar $JBOSS_HOME/standalone/deployments  
    
# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

# Expose the ports we're interested in
EXPOSE 8080 9990

#: For systemd usage this changes to /usr/sbin/init
# Keeping it as /bin/bash for compatability with previous
CMD ["/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
