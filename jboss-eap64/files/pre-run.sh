#!/bin/sh

# Restores original contents of $JBOSS_HOME/standalone/deployments due to erasure upon volume mapping
cp -r /tmp/deployments/* /deployments
rm -rf /tmp/deployments

if [ "$DEV" = true ]; then
	echo ** DEV MODE ON
	echo **** UID: $UID
	echo **** Files on root dir: / \{
	ls -lha /
	echo **** \}
	# binds to all interfaces on debug mode
	export DEBUG=true
	. /opt/eap/bin/standalone.sh -b 0.0.0.0
else
#	. /opt/eap/bin/openshift-launch.sh
	. /opt/eap/bin/standalone.sh
fi