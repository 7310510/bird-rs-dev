#!/bin/sh

echo "# get gobgp"
mkdir gobgp
cd gobgp
curl -L -O https://github.com/osrg/gobgp/releases/download/v1.33/gobgp_1.33_linux_amd64.tar.gz
tar zxvf gobgp_1.33_linux_amd64.tar.gz

echo "# exec vagrant up"
vagrant up
