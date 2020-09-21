# Rancher Auto Deploy

Rancher 自动部署

## 目录结构

## 命令参数

- --online

	指明在线安装或离线安装，true表示在线，false表示离线。离线环境下需要通过`--ansible-offline-images`指定离线镜像。

- --ansible-offline-images

	离线环境下指定ansible镜像，请同步镜像`registry.cn-shanghai.aliyuncs.com/rancher/ansible`到私有仓库。
- --host-groups

	指定主机组。一个主机组代表一个K8S集群，一次只能部署一个K8S集群。此参数的值需要是`hosts`文件中定义的主机组。
- --rke-arg

	自定义rke的运行命令参数，默认运行命令参数为 up，可以通过`--rke-arg=xxx`自定义启动命令，比如：`-d up`。注意：不要指定rke命令和rke配置文件。
- --tags
	通过tags指定运行步骤，比如：--tags=rancher-k8s-install。

## 步骤tags

| 序号 | tag                 | 功能说明                                                     |
| ---- | ------------------- | ------------------------------------------------------------ |
|      | copy-kubectl        | 拷贝kubectl工具到每个节点                                    |
|      | node-clean          | 执行node清理，仅当配置中node_clean=true时执行                |
|      | docker-init         | docker配置初始化，仅当配置中docker_init=true时执行           |
|      | node-init           | node配置优化，仅当配置中node_init=true时执行                 |
|      | ssh-key             | 生成ssh免密认证key                                           |
|      | re-ssh-key          | 重新生成ssh免密认证key                                       |
|      | ssh-user            | ssh用户，用于rke部署K8S                                      |
|      | certs               | rancher前端ssl证书，可在配置中设置为自定义的自签名或者权威ssl证书 |
|      | k8s-cfg             | 生成rke配置文件，用于rke配置文件的检查                                              |
|      | k8s-install         | 安装K8S集群，                                                |
|      | k8s-reinstall       | 重新安装K8S集群，                                            |
|      | k8s-update          | k8s集群升级，                                                |
|      | copy-kubecfg        | 拷贝rke生成的kubecfg文件到每个节点                           |
|      | rancher-install-cfg | 生成rancher安装脚本，用于rancher安装命令参数的检查           |
|      | rancher-install     | 执行rancher安装                                              |
|      | rancher-update-cfg  | 生成rancher更新脚本，用于rancher升级命令参数的检查           |
|      | rancher-update      | 执行rancher升级                                              |
|      | rancher-k8s-install | 安装local集群和rancher                                       |

## 配置参数
`config`目录下保存了节点配置信息和运行需要的环境变量文件。

### hosts文件
hosts文件名称不能改变。hosts文件保存了主机组和主机组中的节点的配置信息，

### 环境变量文件
环境变量文件需要以主机组来命名，比如local.yaml。这样在操作某个主机组时会自动加载对应的环境变量文件。环境变量文件中以键值对的形式保存了执行的所有配置参数。

## 使用示例

### 一键安装Rancher HA
命令行切换到start.sh脚本路径下，执行以下命令：

```bash
bash  start.sh --online=true --host-groups=local --tags=rancher-k8s-install
```

### 仅执行节点初始化

```bash
bash  start.sh --online=true --host-groups=local --tags=node-init
```

### 单独安装K8S

```bash
bash  start.sh --online=true --host-groups=local --tags=k8s-install
```

### 单独升级K8S

```bash
bash  start.sh --online=true --host-groups=local --tags=k8s-update
```

### 单独安装rancher

```bash
bash  start.sh --online=true --host-groups=local --tags=rancher-install
```

### 单独升级rancher

```bash
bash  start.sh --online=true --host-groups=local --tags=rancher-update
```