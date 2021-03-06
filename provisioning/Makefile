JSON=BCE-2016-fall.json

# Detect host operating system
UNAME := $(shell uname)

# Set virtualbox host audio support
BCE_HOST_AUDIO=none
ifeq ($(UNAME),Linux)
	BCE_HOST_AUDIO=alsa
endif
ifeq ($(UNAME),Darwin)
	BCE_HOST_AUDIO=coreaudio
endif

# not sure how to do an 'if' in the json so
# this allows us to copy an empty file if not
# using local copies of source packages
ifeq ($(USE_SAVED_PKG_SRC),False)
	PKG_SRC_FILE=/dev/null
endif


all: vbox ec2

validate:
	packer validate $(JSON)

# https://www.packer.io/docs/builders/amazon.html
# Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables or
# enter creds in ~/.aws/credentials.
ec2:
	PACKER_LOG=100 PACKER_LOG_PATH=packer.log PACKER_NO_COLOR=1 \
	packer build -only=amazon-base \
        -var bce_host_audio=none \
        -var bce_user=ubuntu \
		$(JSON) 2>&1 | tee packer-$@.log 

ec2-cfn:
	PACKER_LOG=100 PACKER_LOG_PATH=packer.log PACKER_NO_COLOR=1 \
	packer build -only=amazon-cfn \
        -var bce_host_audio=none \
        -var bce_user=ubuntu \
		$(JSON) 2>&1 | tee packer-$@.log 

azure:
	PACKER_LOG=100 PACKER_LOG_PATH=packer.log PACKER_NO_COLOR=1 \
	packer build -only=azure \
        -var bce_host_audio=none \
        -var bce_user=packer \
		$(JSON) 2>&1 | tee packer-$@.log

vbox:
	PACKER_LOG=100 PACKER_LOG_PATH=packer.log PACKER_NO_COLOR=1 \
	packer build -only=virtualbox-iso \
        -var bce_host_audio=$(BCE_HOST_AUDIO) \
        -var bce_user=ubuntu \
		$(JSON) 2>&1 | tee packer-$@.log

clean:
	rm -rf build packer-*.log packer.log

distclean: clean
	rm -rf packer_cache
