# setup oski user with admin privileges and for passwordless SSH
adduser oski sudo
cp -pr /home/ubuntu/.ssh /home/oski
chown -R oski:oski /home/oski/.ssh

# add a few useful software packages
apt-get update
apt-get install -y mosh byobu screen tmux git-annex
