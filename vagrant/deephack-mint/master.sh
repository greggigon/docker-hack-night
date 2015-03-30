#!/bin/bash
set -ex

if [ "$#" -lt 2 ]; then
  echo "this script requires 2 arguments: MASTER_IP, OPENSHIFT_VERSION"
  exit 1
fi

MASTER_IP=$1
OPENSHIFT_VERSION=$2

# create systemd unit file
cat << EOF > /tmp/openshift.conf
description "A OpenShift job"
author "Greg Gigon"
manual
start on started docker

script
	docker run --rm -i --name openshift-master --net=host -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/openshift:/var/lib/openshift --privileged openshift/origin:${OPENSHIFT_VERSION} start --master=${MASTER_IP}
end script

post-start script
	sleep 120 && chmod +r "$KUBECONFIG" && chmod +r /var/lib/openshift/openshift.local.certificates/openshift-client/key.key
end script
EOF

sudo mv /tmp/openshift.conf /etc/init/
sudo chown root.root /etc/init/openshift.conf

echo "source /etc/profile.d/openshift.sh" >> ~/.bash_profile

