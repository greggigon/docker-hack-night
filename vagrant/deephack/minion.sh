#!/bin/bash
set -ex

if [ $# != 1 ]; then
  echo "this script requires 1 argument: MASTER_IP"
  exit 1
fi

MASTER_IP=$1

# create systemd unit file
cat << EOF > /usr/lib/systemd/system/openshift-minion.service
[Unit]
Description=OpenShift Minion
After=docker.service iptables.service
Requires=docker.service iptables.service

[Service]
Environment="MASTER_IP=${MASTER_IP}"
Restart=always
ExecStartPre=-/usr/bin/docker rm -f %n
ExecStart=/usr/bin/docker run --rm -i --name %n --net=host -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/openshift:/var/lib/openshift --privileged openshift/origin:${OPENSHIFT_VERSION} start node --master=10.245.2.2
ExecStartPost=sleep 120 && chmod +r "$KUBECONFIG" && chmod +r /var/lib/openshift/openshift.local.certificates/openshift-client/key.keychmod +r "$KUBECONFIG" 
ExecStop=/usr/bin/docker stop -t 5 %n
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

systemctl enable /usr/lib/systemd/system/openshift-minion.service
systemctl start openshift-minion.service
