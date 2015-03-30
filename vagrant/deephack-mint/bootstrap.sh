#!/bin/bash
set -ex

OPENSHIFT_VERSION=$1

sudo sh -c 'echo DOCKER_OPTS=\"--selinux-enabled -H unix://var/run/docker.sock -H tcp://0.0.0.0:2375 --insecure-registry 0.0.0.0/0\" > /etc/default/docker'
sudo service docker restart

# define env
cat << EOF > /etc/profile.d/openshift.sh
export KUBECONFIG=/var/lib/openshift/openshift.local.certificates/admin/.kubeconfig
export CURL_CA_BUNDLE=/var/lib/openshift/openshift.local.certificates/admin/root.crt
export OPENSHIFT_VERSION=${OPENSHIFT_VERSION}
alias openshift="sudo docker run --rm -i --net=host -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/openshift:/var/lib/openshift --privileged openshift/origin:${OPENSHIFT_VERSION}"
alias osc="openshift cli"
EOF

source /etc/profile.d/openshift.sh
