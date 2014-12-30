# Note, 2>&1 redirects to wherever stdout is directed when it gets processed
# Pipes get parsed before redirects
# This is why we place it before the pipe
# See: http://mywiki.wooledge.org/BashFAQ/055
# ps - Bash is just a crazy sorthand for some C code

JSON=BCE-14.04-amd64.json

all: vbox ec2

ec2:
	packer build -only=amazon-ebs     $(JSON) 2>&1 | tee packer-$@-out.log

vbox:
	packer build -only=virtualbox-iso $(JSON) 2>&1 | tee packer-$@-out.log
