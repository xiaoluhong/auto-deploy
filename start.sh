#!/bin/bash

logger()
{
    log=$1
    cur_time='['$(date +"%Y-%m-%d %H:%M:%S")']'
    echo ${cur_time} ${log}
}

help ()
{
    echo  ' ================================================================ '
    echo  ' --online: 指明是在线安装或离线安装，等于true表示在线，false为离线，离线情况下需要指定--ansible-offline-images'
    echo  ' --ansible-offline-images: 离线环境下指定ansible镜像，请同步镜像 registry.cn-shanghai.aliyuncs.com/rancher/ansible 到私有仓库'
    echo  ' --rke-arg: 自定义rke运行参数，默认运行参数为up。可以通过此参数自定义启动命令，比如：-d up。注意：不要指定rke命令和rke配置文件，只需添加运行参数。'
    echo  ' --tags: 通过tags指定步骤运行'
    echo  ' ================================================================'
}

case "$1" in
    -h|--help) help; exit;;
esac

if [[ $1 == '' ]];then
    help;
    exit;
fi

CMDOPTS="$*"
for OPTS in $CMDOPTS;
do
    KEY=$(echo ${OPTS} | awk -F"=" '{print $1}' )
    VALUE=$(echo ${OPTS} | awk -F"=" '{print $2$3$4$5}' )
    case "$KEY" in
        --online) ONLINE=${VALUE} ;;
        --ansible-offline-images) ANSIBLE_OFFLINE_IMAGES=${VALUE} ;;
        --rke-arg) RKE_ARG=${VALUE} ;;
        --tags) TAGS=${VALUE} ;;
    esac
done

DIR_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

touch history.log
echo " $(date +"%Y-%m-%d-%H:%M:%S") $(basename $0) $* " >> history.log

# 给脚本执行权限
ANSIBLE_OFFLINE_IMAGES=$ANSIBLE_OFFLINE_IMAGES
HOST_GROUPS=${HOST_GROUPS}
TAGS=${TAGS}
ONLINE=${ONLINE}
RKE_ARG=${RKE_ARG:-'up'}

chmod +x ./bin/*
ANSIBLE_ONLINE_IMAGES=registry.cn-shanghai.aliyuncs.com/rancher/ansible

# 获取主机组
LOCAL_HOST_GROUPS=$( cat config/hosts | grep -v '#' | grep "\\[.*\\]" | awk -F'[' '{print $2}' | awk -F']' '{print $1}' | grep local )
CUSTOM_HOST_GROUPS=$( cat config/hosts | grep -v '#' | grep "\\[.*\\]" | awk -F'[' '{print $2}' | awk -F']' '{print $1}' | grep custom )
IMPORT_HOST_GROUPS=$( cat config/hosts | grep -v '#' | grep "\\[.*\\]" | awk -F'[' '{print $2}' | awk -F']' '{print $1}' | grep import )
RKE_HOST_GROUPS=$( cat config/hosts | grep -v '#' | grep "\\[.*\\]" | awk -F'[' '{print $2}' | awk -F']' '{print $1}' | grep rke )

# 拉取或者指定ansible镜像
if [[ ${ONLINE} == true ]]; then
    docker pull ${ANSIBLE_ONLINE_IMAGES};
elif [[ ${ONLINE} == false ]]; then
    if [[ ! -n ${ANSIBLE_OFFLINE_IMAGES} ]]; then
        logger "未指定离线ansible镜像";
        help;
        exit;
    fi
else
    logger "--online参数配置不正确";
    help;
    exit;

fi

# loca 集群操作
if [[ -n $LOCAL_HOST_GROUPS ]]; then

    for local_host_group in $LOCAL_HOST_GROUPS;
    do
        echo "当前操作 $local_host_group 集群中..."
        if [[ ${ONLINE} == true ]]; then
            docker run --rm -ti \
            -v ${DIR_ROOT}:/etc/ansible \
            -e ONLINE=${ONLINE} \
            ${ANSIBLE_ONLINE_IMAGES} \
            ansible-playbook ./roles/local-k8s-rancher.yaml --extra-vars "host_groups=${local_host_group} rke_arg=${RKE_ARG} cluster_type=local" `if [[ -n $TAGS ]]; then echo "--tags=${TAGS}"; fi`;
        else
            docker run --rm -ti \
            -v ${DIR_ROOT}:/etc/ansible \
            -e ONLINE=${ONLINE} \
            ${ANSIBLE_OFFLINE_IMAGES} \
            ansible-playbook ./roles/local-k8s-rancher.yaml --extra-vars "host_groups=${local_host_group} rke_arg=${RKE_ARG} cluster_type=local" `if [[ -n $TAGS ]]; then echo "--tags=${TAGS}"; fi`;
        fi
    done
fi

# custom 集群操作
if [[ -n $CUSTOM_HOST_GROUPS ]]; then

    for custom_host_group in $CUSTOM_HOST_GROUPS;
    do
        echo "当前操作 $custom_host_group 集群中..."
        if [[ ${ONLINE} == true ]]; then
            docker run --rm -ti \
            -v ${DIR_ROOT}:/etc/ansible \
            -e ONLINE=${ONLINE} \
            ${ANSIBLE_ONLINE_IMAGES} \
            ansible-playbook ./roles/custom-k8s-rancher.yaml --extra-vars "host_groups=${custom_host_group} rke_arg=${RKE_ARG} cluster_type=custom" `if [[ -n $TAGS ]]; then echo "--tags=${TAGS}"; fi`;
        else
            docker run --rm -ti \
            -v ${DIR_ROOT}:/etc/ansible \
            -e ONLINE=${ONLINE} \
            ${ANSIBLE_OFFLINE_IMAGES} \
            ansible-playbook ./roles/custom-k8s-rancher.yaml --extra-vars "host_groups=${custom_host_group} rke_arg=${RKE_ARG} cluster_type=custom" `if [[ -n $TAGS ]]; then echo "--tags=${TAGS}"; fi`;
        fi
    done
fi

# import 集群操作
if [[ -n $IMPORT_HOST_GROUPS ]]; then

    for import_host_group in $IMPORT_HOST_GROUPS;
    do
        echo "当前操作 $import_host_group 集群中..."
        if [[ ${ONLINE} == true ]]; then
            docker run --rm -ti \
            -v ${DIR_ROOT}:/etc/ansible \
            -e ONLINE=${ONLINE} \
            ${ANSIBLE_ONLINE_IMAGES} \
            ansible-playbook ./roles/import-k8s-rancher.yaml --extra-vars "host_groups=${import_host_group} rke_arg=${RKE_ARG} cluster_type=import" `if [[ -n $TAGS ]]; then echo "--tags=${TAGS}"; fi`;
        else
            docker run --rm -ti \
            -v ${DIR_ROOT}:/etc/ansible \
            -e ONLINE=${ONLINE} \
            ${ANSIBLE_OFFLINE_IMAGES} \
            ansible-playbook ./roles/import-k8s-rancher.yaml --extra-vars "host_groups=${import_host_group} rke_arg=${RKE_ARG} cluster_type=import" `if [[ -n $TAGS ]]; then echo "--tags=${TAGS}"; fi`;
        fi
    done
fi

# rke 集群操作
if [[ -n $RKE_HOST_GROUPS ]]; then

    for rke_host_group in $RKE_HOST_GROUPS;
    do
        echo "当前操作 $rke_host_group 集群中..."
        if [[ ${ONLINE} == true ]]; then
            docker run --rm -ti \
            -v ${DIR_ROOT}:/etc/ansible \
            -e ONLINE=${ONLINE} \
            ${ANSIBLE_ONLINE_IMAGES} \
            ansible-playbook ./roles/rke-k8s-rancher.yaml --extra-vars "host_groups=${rke_host_group} rke_arg=${RKE_ARG} cluster_type=rke" `if [[ -n $TAGS ]]; then echo "--tags=${TAGS}"; fi`;
        else
            docker run --rm -ti \
            -v ${DIR_ROOT}:/etc/ansible \
            -e ONLINE=${ONLINE} \
            ${ANSIBLE_OFFLINE_IMAGES} \
            ansible-playbook ./roles/rke-k8s-rancher.yaml --extra-vars "host_groups=${rke_host_group} rke_arg=${RKE_ARG} cluster_type=rke" `if [[ -n $TAGS ]]; then echo "--tags=${TAGS}"; fi`;
        fi
    done
fi