#!/bin/bash

# copy this file to (or paste the contents into) a
# text file on the VM
# run this script as: 
#    sudo bash modify-for-aws.sh
# it will take a minute or two to complete

# setup oski user with admin privileges and for passwordless SSH
adduser oski sudo
cp -pr /home/ubuntu/.ssh /home/oski
chown -R oski:oski /home/oski/.ssh

# add a few useful software packages
apt-get update
apt-get install -y mosh byobu screen tmux git-annex
