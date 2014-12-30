#!/usr/bin/bash

# Make it easy to set up password / encryption for IPython notebook

echo "
This script will update your default ipython notebook profile.
It will be configured to use the SSL certificate it creates in the
current directory.

Please type a password to use for the notebook server:"
sha_str=$(python -c \
	  'from IPython.lib import passwd; print passwd(raw_input())' )
# Just for the vertical space
echo 

# Create the ipython profile_default
ipython profile create

# There's probably a slightly better way to get this filename
cfile=~/.ipython/profile_default/ipython_notebook_config.py
cat >> $cfile <<EOF

# Automatically added by setup_ipython_notebook.sh
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 9999
c.NotebookApp.certfile = u'$PWD/ipython.pem'
c.NotebookApp.password = u'$sha_str'
EOF

echo "Added config to end of:
    $cfile

Generating SSL certificate. Answer questions however you like.
(Hit enter to continue)"

# We don't care what they type, as long as they hit enter
read

# Generate a reasonable SSL cert
openssl req -x509 -nodes -days 365 -newkey rsa:1024 \
	-keyout ipython.pem -out ipython.pem

# Thanks internet!
myip=$(dig +short myip.opendns.com @resolver1.opendns.com)

echo "
The following line should now run the notebook on port 9999
    \$ ipython notebook

To modify this behavior (including if you move ipython.pem) edit:
    $cfile

You'll also need to open TCP access from your web browser's IP. For example,
using Amazon's EC2 console, click on the security group for your instance and
add an incoming rule for port 9999.

Then, you should be able to point your (local) web browser to:
    https://$myip:9999/

You'll probably need to click through security warnings in Chrome each time.
Firefox should let you save the certificate for future usage.

Your password will be the one you typed above. It's in cleartext, so you can
check if you've forgotten already!
"
