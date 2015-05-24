#!/bin/bash
sudo rpm --import https://packages.elasticsearch.org/GPG-KEY-elasticsearch
sudo cat <<EOF > /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-1.4] 
name=Elasticsearch repository for 1.4.x packages 
baseurl=http://packages.elasticsearch.org/elasticsearch/1.4/centos
gpgcheck=1
gpgkey=http://packages.elasticsearch.org/GPG-KEY-elasticsearch
enabled=1
EOF
sudo yum install elasticsearch
echo yes
sudo service elasticsearch start
