#!/bin/bash
set -ex

if [ "$#" -lt 2 ]; then
  echo "this script requires 2 arguments: MASTER_IP [MINION_IPS]"
  exit 1
fi

MASTER_IP=$1
MINION_IPS=$2

cat << EOF > /etc/sysconfig/iptables
# sample configuration for iptables service
# you can edit this manually or use system-config-firewall
# please do not ask us to add additional ports/services to this default configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 10250 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8443:8444 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 7001 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 4001 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
systemctl restart iptables
systemctl restart docker

# create systemd unit file
cat << EOF > /usr/lib/systemd/system/openshift-master.service
[Unit]
Description=OpenShift Master
After=docker.service iptables.service
Requires=docker.service iptables.service

[Service]
Environment="MASTER_IP=${MASTER_IP}"
Environment="MINION_IPS=${MINION_IPS}"
Restart=always
ExecStartPre=-/usr/bin/docker rm -f %n
ExecStart=/usr/bin/docker run --rm -i --name %n --net=host -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/openshift:/var/lib/openshift --privileged openshift/origin:${OPENSHIFT_VERSION} start --master=${MASTER_IP}
ExecStartPost=sleep 120 && chmod +r "$KUBECONFIG" && chmod +r /var/lib/openshift/openshift.local.certificates/openshift-client/key.key
ExecStop=/usr/bin/docker stop -t 5 %n
TimeoutStartSec=300

[Install]
WantedBy=multi-user.target
EOF

systemctl enable /usr/lib/systemd/system/openshift-master.service
systemctl start openshift-master.service
