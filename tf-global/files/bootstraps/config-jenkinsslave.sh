#!/bin/bash
set -e
# TODO - put all of this in a proper CM tool like ansible... ugh :(
# install jenkins
sudo yum update -y
sudo yum -y install java-1.8.0-openjdk
echo "--------Java installed"
# some useful tools
sudo yum -y install wget telnet bind-utils nano git
echo "--------Utilities installed"
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum -y install python36u python36u-pip 
sudo pip3.6 install awscli 
echo "--------Python3,PIP,AWSCLI has been installed"
#setup timezone
#sudo timedatectl set-timezone America/Los_Angeles
#echo "--------Timezone has been set"
#slave setup...
sudo useradd --system -U -d /var/lib/jenkins -m -s /bin/bash jenkins
#sudo install -d -o jenkins -g jenkins /var/lib/jenkins
sudo install -d -m 700 -o jenkins -g jenkins /var/lib/jenkins/.ssh
sudo touch /var/lib/jenkins/.ssh/authorized_keys
sudo chown jenkins.jenkins /var/lib/jenkins/.ssh/authorized_keys -R
sudo chmod 600 /var/lib/jenkins/.ssh/authorized_keys -R
echo "--------Jenkins slave user created and prepped for manual key entry from master"
echo "--------TODO: make sure you import keys from master into slave's authorized_keys file"
echo "--------TODO: /var/lib/jenkins-slave/.ssh/authorized_keys"
sudo hostnamectl set-hostname ${thehostname}
echo "--------Changed the hostname as requested"
# copy the id_rsa.pub from jenkins master to jenkins slave authorized keys (do manually for now)
#vi /var/lib/jenkins-slave/.ssh/authorized_keys
#   copy jenkinsmasterhost:/var/lib/jenkins/ssh/id_rsa.pub