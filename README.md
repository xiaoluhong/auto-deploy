# Auto-deploy

Rancher 自动部署

## 功能说明

- 默认禁用Ingress代理，启用外部七层代理
- 可选择Nodeport方式访问，自定义Nodeport端口
- 自定义Pod数量
- 自定义ClusterIP
- 默认开启ETCD自动备份,可以自定义关闭
- 指定默认镜像仓库
- k8s基础调优

## 运行逻辑说明

1. 节点初始化
  - 配置节点免密登录
  - 检查主机名是否标准
  - 配置主机别名(hosts)
  - 清理Docker残留容器
  - 清理K8S残留文件
  - 清理ETCD残留文件
  - 清理RKE残留文件
  - 清理Rancher残留文件
  - 关闭Selinux(centos、Redhat等)
  - 关闭防火墙
  - 修改内核参数
    - No memory limit support
    - Bridge-nf-call-ip(ipv6)tables is disabled
    - WARNING IPv4 forwarding is disabled
  - 配置非安全仓库(默认为私有仓库)
  - //Docker加速地址(默认https://7bezldxe.mirror.aliyuncs.com)
  - //如果私有仓库有Haproxy、Tiller、Keepalived镜像则直接拉取，没有则分发镜像压缩包到节点

1. 本地更新配置文件
  - 生成ssh key
  - 生成自签名ssl证书（默认自动生成）
  - 生成RKE配置文件

1. 安装Local集群
  - 安装过程中会临时创建`rancher`用户，避免用户不合乎要求导致rke部署失败。
	- 安装Ingress和Haproxy、Keepalived
	  - 场景1：默认将安装Haproxy、Keepalived，可以在`hosts`文件中通过变量启用或关闭。Ingress与Haproxy、Keepalived互斥，只在未部署Haproxy、Keepalived的节点上部署Ingress.Haproxy、Keepalived将同时运行在一个节点上。
	  - 场景2：当使用外部负载均衡器时(比如F5之类)，禁止在节点部署Haproxy、Keepalived，所有节点将部署Ingress。

1. 安装Rancher
  - 配置Helm客户端访问权限
  - 安装Helm客户端（默认已安装）
  - 安装Helm Server(Tiller)
  - 安装Rancher Server