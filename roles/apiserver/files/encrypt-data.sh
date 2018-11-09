#!/bin/bash
config()
{
export ENCRYPT_KEY=$(head -c 32 /dev/urandom | base64)

cat <<EOF > /etc/kubernetes/encrypt-data.yaml
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: ${ENCRYPT_KEY}
    - identity: {}
EOF
}

##配置加密数据
##复制至其他master
LOCAL_IP=`ip addr|grep eno16777984|grep inet|awk '{print $2}'|cut -c 1-10|head -1`
MASTER1='10.0.31.51'
if [ $LOCAL_IP == $MASTER1 ];
then
    config
    scp /etc/kubernetes/encrypt-data.yaml root@master2:/etc/kubernetes/
fi

