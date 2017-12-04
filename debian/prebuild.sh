#!/usr/bin/env bash
sudo apt-get update
sudo apt-get install -y lsb-release

echo "Installing Tarantool 1.7"
release=`lsb_release -c -s`

curl http://download.tarantool.org/tarantool/1.7/gpgkey | sudo apt-key add -

# install https download transport for APT
sudo apt-get -y install apt-transport-https

# append two lines to a list of source repositories
sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
release=${release} sudo tee /etc/apt/sources.list.d/tarantool_1_7.list <<- EOF
deb http://download.tarantool.org/tarantool/1.7/${OS}/ ${release} main
deb-src http://download.tarantool.org/tarantool/1.7/${OS}/ ${release} main
EOF

# install
sudo apt-get update
sudo apt-get -y install tarantool
