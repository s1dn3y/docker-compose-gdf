#!/bin/bash
# version 1.0
# https://github.com/ssbarnea/keytool-trust
REMHOST=$1
REMPORT=${2:-443}

KEYSTORE_PASS=changeit
KEYTOOL="$JAVA_HOME/bin/keytool"

# /etc/java-6-sun/security/cacerts

for CACERTS in $JAVA_HOME/jre/lib/security/cacerts
do

if [ -e "$CACERTS" ]
then
    echo --- Adding certs to $CACERTS

# FYI: the default keystore is located in ~/.keystore

if [ -z "$REMHOST" ]
    then
    echo "ERROR: Please specify the server name to import the certificatin from, eventually followed by the port number, if other than 443."
    exit 1
    fi

set -e

rm -f $REMHOST:$REMPORT.pem

if openssl s_client -connect $REMHOST:$REMPORT 1>/tmp/keytool_stdout 2>/tmp/output </dev/null
        then
        :
        else
        cat /tmp/keytool_stdout
        cat /tmp/output
        exit 1
        fi

if sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' </tmp/keytool_stdout > /tmp/$REMHOST:$REMPORT.pem
        then
        :
        else
        echo "ERROR: Unable to extract the certificate from $REMHOST:$REMPORT ($?)"
        cat /tmp/output
        fi

if $KEYTOOL -list -storepass ${KEYSTORE_PASS} -alias $REMHOST:$REMPORT >/dev/null
    then
    echo "$REMHOST already found, skipping it."
#    $KEYTOOL -delete -alias $REMHOST:$REMPORT -storepass ${KEYSTORE_PASS}
    else
    $KEYTOOL -import -trustcacerts -noprompt -storepass ${KEYSTORE_PASS} -alias $REMHOST:$REMPORT -file /tmp/$REMHOST:$REMPORT.pem
    fi

if $KEYTOOL -list -storepass ${KEYSTORE_PASS} -alias $REMHOST:$REMPORT -keystore "$CACERTS" >/dev/null
    then
    echo "$REMHOST already found in cacerts, skipping it."
    else
    $KEYTOOL -import -trustcacerts -noprompt -keystore "$CACERTS" -storepass ${KEYSTORE_PASS} -alias $REMHOST:$REMPORT -file /tmp/$REMHOST:$REMPORT.pem
    fi

fi

done
