#!/bin/bash

# 给脚本执行权限
sudo chmod +x ./ansible/bin/create-cert.sh ./ansible/bin/run.sh

# 导入rancher-ansible镜像
if ! docker images |grep -qiE registry.cn-shanghai.aliyuncs.com/rancher/ansible ; then 
    gunzip -c rancher-ansible.tgz | docker load
fi

init()
{
    docker run --rm -ti --network host \
    -v $PWD/ansible:/etc/ansible  \
    registry.cn-shanghai.aliyuncs.com/rancher/ansible \
    ansible-playbook -e host_group=local /etc/ansible/roles/init.yaml
}
install_init_local()
{
    docker run --rm -ti --network host \
    -v $PWD/ansible:/etc/ansible  \
    registry.cn-shanghai.aliyuncs.com/rancher/ansible \
    ansible-playbook /etc/ansible/roles/install-local.yaml 
}
install_init_k8s()
{
    #docker run --rm -ti --network host \
    #-v $PWD/ansible:/etc/ansible  \
    #registry.cn-shanghai.aliyuncs.com/rancher/ansible \
    #ansible-playbook /etc/ansible/roles/install-k8s.yaml
}
all()
{
    docker run --rm -ti --network host \
    -v $PWD/ansible:/etc/ansible  \
    registry.cn-shanghai.aliyuncs.com/rancher/ansible \
    ansible-playbook -e host_group=local /etc/ansible/roles/all.yaml
}
help ()
{
    echo  ' ================================================================ '
    echo  ' --init: 仅初始化所有节点；'
    echo  ' --install-local: 安装local集群和rancher server'
    echo  ' --install-k8s: 安装业K8S集群(todo)'
    echo  ' --all: 初始化集群、安装local集群、安装业务集群'
    echo  ' ================================================================'
}
case "$1" in
    -h|--help|) help; exit;;
esac

CMDOPTS="$*"
for OPTS in $CMDOPTS;
do
    key=$(echo ${OPTS} | awk -F"=" '{print $1}' )
    value=$(echo ${OPTS} | awk -F"=" '{print $2}' )
    case "$key" in
        --init) init ;;
        --install-local) install_local ;;
        --install-k8s) install_k8s ;;
        --all) all ;;
    esac
done

#docker save registry.cn-shanghai.aliyuncs.com/rancher/ansible | gzip > rancher-ansible.tar.gz
#gunzip -c rancher-ansible.tar.gz | docker load
