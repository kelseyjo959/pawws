#!/bin/bash

echo "installing mongodb"

sudo apt-get install dirmngr --install-recommends

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5

apt-get update

apt-get install -y mongodb

#systemctl start mongodb


echo "installing nokogiri"

sudo apt-get install build-essential patch ruby-dev zlib1g-dev liblzma-dev

gem install nokogiri

echo "installing nodejs and npm"

apt-get install curl

apt-get update

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

apt-get install -y nodejs

apt-get install npm

gem install mongoid
