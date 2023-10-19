#!/bin/env bash

cd /var/tmp
# Download the latest oc client
/bin/curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz -o openshift-client-linux.tar.gz

# Extract it
/bin/tar xvf openshift-client-linux.tar.gz > /dev/null 2>&1

# Login to Openshift
./oc login -u ${admin_user} -p ${admin_password} https://api.${domain}:6443 > /dev/null 2>&1
