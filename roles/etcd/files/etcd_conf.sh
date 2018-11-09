#!/bin/bash
##设置相应变量
export ETCD_NAME=etcd-$(ip addr|grep eno16777984|grep inet|awk '{print $2}'|cut -c 9-10|head -1)
export LOCAL_IP=$(ip addr|grep eno16777984|grep inet|awk '{print $2}'|cut -c 1-10|head -1)
export ETCD_CLUSTER="etcd-51=https://10.0.31.51:2380,etcd-52=https://10.0.31.52:2380,etcd-53=https://10.0.31.53:2380"

##配置 etcd
cat << EOF > /etc/etcd/etcd.conf 
name: '${ETCD_NAME}'
heartbeat-interval: 2000     ##心跳间隔时间(以毫秒为单位)
election-timeout: 10000      ##超时选举时间,与心跳间隔时间至少5倍(以毫秒为单位)
data-dir: "/var/lib/etcd/"
listen-peer-urls: https://${LOCAL_IP}:2380
listen-client-urls: https://${LOCAL_IP}:2379,https://127.0.0.1:2379
initial-advertise-peer-urls: https://${LOCAL_IP}:2380
advertise-client-urls: https://${LOCAL_IP}:2379
initial-cluster: "${ETCD_CLUSTER}"
initial-cluster-token: 'etcd-cluster'
initial-cluster-state: 'new'   ##初始化集群状态('new' or 'existing')
client-transport-security:
  cert-file: /etc/kubernetes/ssl/etcd.pem
  key-file: /etc/kubernetes/ssl/etcd-key.pem
  trusted-ca-file: /etc/kubernetes/ssl/ca.pem
peer-transport-security:
  cert-file: /etc/kubernetes/ssl/etcd.pem
  key-file: /etc/kubernetes/ssl/etcd-key.pem
  trusted-ca-file: /etc/kubernetes/ssl/ca.pem
EOF

##启用 etcd
systemctl daemon-reload
systemctl start etcd
systemctl enable etcd

