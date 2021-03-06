FROM centos:latest
#USER root

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 10.0.0.Final
ENV JB_CON wildfly-mongo.jarvis-sit.svc
ENV JBOSS_HOME /wildfly
ENV JBOSS_KEY $JBOSS_HOME/keycloak-1.9.4.Final

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place

RUN cd $HOME && \
 #   yum install tar java jdk zip unzip wget curl sudo -y && \
    wget "http://downloads.jboss.org/keycloak/1.9.4.Final/keycloak-overlay-1.9.4.Final.tar.gz" && \
    mv keycloak-overlay-1.9.4.Final.tar.gz keycloak-distro-overlay.tar.gz && \
    tar zxvf keycloak-distro-overlay.tar.gz -C $JBOSS_HOME --strip-components=1 && \
    chmod -R 777 /wildfly && \
    chown -R default:root /wildfly && \ 
    cd $JBOSS_HOME/standalone && \
  #  mkdir log && \
  #  mkdir data && \
   # mkdir tmp/vfs && \
    #mkdir tmp/vfs/temp && \
#    chmod a+w log && \
 #   chown -R 1000050000:root log && \
 #   chmod a+w tmp && \
 #   chmod a+w data && \
 #   chown -R 1000050000:root data && \
#    chmod a+w deployments && \
    cd $HOME
    
#RUN $JBOSS_HOME/keycloak-1.9.4.Final/bin/add-user.sh admin P@ssw0rd10 --silent
ADD mongojdbc1.2.jar $JBOSS_HOME/standalone/deployments
ADD postgresql-9.4.1208.jar $JBOSS_HOME/standalone/deployments  
#ADD jboss-modules.jar $JBOSS_HOME/standalone/deployments
ADD standalone.xml $JBOSS_HOME/standalone/configuration
RUN sed -i 's/jboss.bind.address.management:127.0.0.1/jboss.bind.address.management:0.0.0.0/g' $JBOSS_HOME/standalone/configuration/standalone.xml
#RUN $JBOSS_HOME/bin/add-user-keycloak.sh -r master -u admin -p P@ssw0rd10
    
# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

# Expose the ports we're interested in
EXPOSE 8080 9990

#: For systemd usage this changes to /usr/sbin/init
# Keeping it as /bin/bash for compatability with previous
#user root
CMD ["/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
