echo "Installing Tarantool 1.7"

sudo rm -f /etc/yum.repos.d/*tarantool*.repo
sudo tee /etc/yum.repos.d/tarantool_1_7.repo <<- EOF
[tarantool_1_7]
name=Fedora-\$releasever - Tarantool
baseurl=http://download.tarantool.org/tarantool/1.7/fedora/\$releasever/x86_64/
gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
repo_gpgcheck=1
gpgcheck=0
enabled=1

[tarantool_1_7-source]
name=Fedora-\$releasever - Tarantool Sources
baseurl=http://download.tarantool.org/tarantool/1.7/fedora/\$releasever/SRPMS
gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
repo_gpgcheck=1
gpgcheck=0
EOF

sudo dnf -q makecache -y --disablerepo='*' --enablerepo='tarantool_1_7'
sudo dnf -y install tarantool
