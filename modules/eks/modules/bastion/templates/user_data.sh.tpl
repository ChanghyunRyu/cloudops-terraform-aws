#!/bin/bash -xe

# 업데이트 및 필수 도구 설치
yum update -y
yum install -y curl unzip tar git jq

# AWS CLI v2 설치
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
./aws/install
export PATH=$PATH:/usr/local/bin

# kubectl 1.32.0 설치
curl -o /usr/local/bin/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.32.0/2024-12-20/bin/linux/amd64/kubectl
chmod +x /usr/local/bin/kubectl

# eksctl 설치
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /usr/local/bin

# EC2의 지역 정보 가져오기
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

# kubeconfig 생성
aws eks update-kubeconfig --name ${cluster_name} --region $REGION

echo "✅ Bastion Host provisioning completed."
