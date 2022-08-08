#!/bin/sh

while inotifywait -r /home/cloud/Ideaprojects/minikube-mnt/jenkins/workspace/splunkdemo/hsbc_wpb_acs/local/*; do
#rsync -avu --delete    
rsync -avz /home/cloud/Ideaprojects/minikube-mnt/jenkins/workspace/splunkdemo/hsbc_wpb_acs/local /home/cloud/Ideaprojects/minikube-mnt/splunk-hsbc/hsbc_wpb_acs
done
