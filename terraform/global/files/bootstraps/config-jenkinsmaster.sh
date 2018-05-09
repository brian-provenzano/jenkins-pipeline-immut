#!/bin/bash
set -e
# TODO - put all of this in a proper CM tool like ansible... ugh :(
# install jenkins
sudo yum update -y
sudo yum -y install wget
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
sudo yum -y install java-1.8.0-openjdk jenkins -y
echo "--------Jenkins,Java installed"
#uncomment the below if you want to lock to a certain version of jenkins 
#sudo yum-config-manager --disable jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
echo "--------Jenkins enabled and started"
# some useful tools
sudo yum install telnet bind-utils nano git -y
echo "--------Utilities have been installed"
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum -y install python36u python36u-pip
sudo pip3.6 install awscli
echo "--------Python3,PIP,AWSCLI has been installed"
#setup timezone
#sudo timedatectl set-timezone America/Los_Angeles
#echo "--------Timezone has been set"
#setup keys for jenkins
sudo -i su -c "ssh-keygen -b 2048 -t rsa -f /var/lib/jenkins/.ssh/id_rsa -q -N \"\"" -m "jenkins"
echo "--------Jenkins user ssh keys generated"
sudo hostnamectl set-hostname ${thehostname}
echo "--------Changed the hostname as requested"