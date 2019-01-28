#!/bin/bash

# 创建证书目录
mkdir -p cert

ansible-playbook /etc/ansible/roles/all.yaml
