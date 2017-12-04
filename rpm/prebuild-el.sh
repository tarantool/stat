#!/usr/bin/env bash
echo "Installing Tarantool 1.7"

sudo yum clean all
sudo yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-${DIST}.noarch.rpm
sudo sed 's/enabled=.*/enabled=1/g' -i /etc/yum.repos.d/epel.repo
sudo rm -f /etc/yum.repos.d/*tarantool*.repo
sudo tee /etc/yum.repos.d/tarantool_1_7.repo <<- EOF
[tarantool_1_7]
name=EnterpriseLinux-${DIST} - Tarantool
baseurl=http://download.tarantool.org/tarantool/1.7/el/${DIST}/x86_64/
gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
repo_gpgcheck=1
gpgcheck=0
enabled=1

[tarantool_1_7-source]
name=EnterpriseLinux-${DIST} - Tarantool Sources
baseurl=http://download.tarantool.org/tarantool/1.7/el/${DIST}/SRPMS
gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
repo_gpgcheck=1
gpgcheck=0
EOF

sudo yum makecache -y --disablerepo='*' --enablerepo='tarantool_1_7' --enablerepo='epel'
sudo yum -y install tarantool
