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
#https://aws.amazon.com/premiumsupport/knowledge-center/linux-static-hostname-rhel7-centos7/
sudo hostnamectl set-hostname --static ${thehostname}
sudo echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
echo "--------Changed the hostname as requested"
sudo yum remove docker docker-common docker-selinux docker-engine
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum makecache fast
yum install -y --setopt=obsoletes=0 docker-ce-17.03.0.ce-1.el7.centos docker-ce-selinux-17.03.0.ce-1.el7.centos
echo "--------Docker 17.03.0.ce-1.el7 installed"
sudo systemctl start docker
sudo systemctl enable docker
echo "--------Docker 17.03.0.ce-1.el7 started and enabled at boot"
# copy the id_rsa.pub from jenkins master to jenkins slave authorized keys (do manually for now)
#vi /var/lib/jenkins-slave/.ssh/authorized_keys
#   copy jenkinsmasterhost:/var/lib/jenkins/ssh/id_rsa.pub

#-----optional for java builds
# #JDK
# sudo yum -y install java-1.8.0-openjdk-devel
# #ant
# sudo tar -zxf apache-ant-1.10.1-bin.tar.gz -C /opt
# sudo ln -s /opt/apache-ant-1.10.1/ /opt/ant
# sudo sh -c 'echo ANT_HOME=/opt/ant >> /etc/environment'
# sudo ln -s /opt/ant/bin/ant /usr/bin/ant