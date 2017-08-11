FROM registry.access.redhat.com/jboss-eap-7/eap70-openshift

# changes uid and gid of user and group jboss to 1000 (because
# this value is related to host's first created user, at installation),
# so that the volume's gets adjusted

USER root
RUN usermod -u 1000 jboss \
 && groupmod -g 1000 jboss

# saves original contents of '$JBOSS_HOME/standalone/deployments'
USER jboss
RUN mkdir /tmp/deployments \
 && cp -r /deployments/* /tmp/deployments

EXPOSE 8080 8443 8778 8787 9990
VOLUME /deployments

COPY files/pre-run.sh /opt/eap/bin/

USER root
RUN chmod 755 /opt/eap/bin/pre-run.sh \
 && chown -R jboss:jboss /opt/eap

# create jboss' administration login
USER jboss
RUN $JBOSS_HOME/bin/add-user.sh admin @dmin123456 --silent

# restores original contents of '$JBOSS_HOME/standalone/deployments' (saved in /tmp/deployments) dir and starts jboss
USER jboss
CMD /opt/eap/bin/pre-run.sh