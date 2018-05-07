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
#setup keys for jenkins
sudo -i su -c "ssh-keygen -b 2048 -t rsa -f /var/lib/jenkins/.ssh/id_rsa -q -N \"\"" -m "jenkins"
echo "--------Jenkins user ssh keys generated"
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
#-----optional for java builds
# #JDK
# sudo yum -y install java-1.8.0-openjdk-devel
# #ant
# sudo tar -zxf apache-ant-1.10.1-bin.tar.gz -C /opt
# sudo ln -s /opt/apache-ant-1.10.1/ /opt/ant
# sudo sh -c 'echo ANT_HOME=/opt/ant >> /etc/environment'
# sudo ln -s /opt/ant/bin/ant /usr/bin/ant