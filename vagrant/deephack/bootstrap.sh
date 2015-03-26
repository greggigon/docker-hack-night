#!/bin/bash
set -ex

OPENSHIFT_VERSION=$1

systemctl stop firewalld
systemctl disable firewalld
systemctl enable iptables
systemctl start iptables

sed -i "/^OPTIONS/ s|.*|OPTIONS='--selinux-enabled -H unix://var/run/docker.sock -H tcp://0.0.0.0:2375 --insecure-registry 0.0.0.0/0'|" /etc/sysconfig/docker
systemctl daemon-reload
systemctl restart docker

# define env
cat << EOF > /etc/profile.d/openshift.sh
export KUBECONFIG=/var/lib/openshift/openshift.local.certificates/admin/.kubeconfig
export CURL_CA_BUNDLE=/var/lib/openshift/openshift.local.certificates/admin/root.crt
export OPENSHIFT_VERSION=${OPENSHIFT_VERSION}
alias openshift="sudo docker run --rm -i --net=host -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/openshift:/var/lib/openshift --privileged openshift/origin:${OPENSHIFT_VERSION}"
alias osc="openshift cli"
EOF

source /etc/profile.d/openshift.sh

cat << EOF > /usr/lib/systemd/system/cadvisor.service
[Unit]
Description=cAdvisor
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStartPre=-/usr/bin/docker rm -f %n
#ExecStartPre=/usr/bin/docker pull google/cadvisor
ExecStart=/usr/bin/docker run --volume=/:/rootfs:ro --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --publish=9080:8080 --name=%n google/cadvisor:latest --logtostderr
ExecStop=/usr/bin/docker stop -t 5 %n
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

systemctl enable /usr/lib/systemd/system/cadvisor.service
systemctl start cadvisor.service
