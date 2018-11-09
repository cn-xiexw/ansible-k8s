#!/bin/bash
config()
{
export KUBE_APISERVER="https://10.0.31.60:8443"
cd /etc/kubernetes/

## 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=controller-manager.kubeconfig 

## 设置客户端认证参数
kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=/etc/kubernetes/ssl/controller-manager.pem \
  --client-key=/etc/kubernetes/ssl/controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=controller-manager.kubeconfig

## 设置关联参数
kubectl config set-context system:kube-controller-manager \
  --cluster=kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=controller-manager.kubeconfig

## 设置默认关联
kubectl config use-context system:kube-controller-manager \
  --kubeconfig=controller-manager.kubeconfig
}

copy-config()
{
  MASTER=(master1 master2)
  for node_name in ${MASTER[@]}
  do
    echo ">>> ${node_name}"
    scp /etc/kubernetes/controller-manager.kubeconfig root@${node_name}:/etc/kubernetes/
  done
}

## 配置 controller-manager.kubeconfig 并复制至其他 master,local_address必须读取出vip地址
#LOCAL_IP=`ip addr|grep ens33|grep inet|awk '{print $2}'|cut -c 1-15`
LOCAL_ADDRESS=`ip addr|grep secondary|awk '{print $2}'|cut -c 1-10|tail -1`
VIP='10.0.31.60'
if [ $LOCAL_ADDRESS == $VIP ];
then
    config
    copy-config
fi
