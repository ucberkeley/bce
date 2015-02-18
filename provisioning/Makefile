JSON=BCE-14.10-amd64.json

USE_SAVED_PKG_SRC=True
PKG_SRC_FILE=/tmp/2015-spring-package-cache.zip

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

ec2:
	packer build -only=amazon-ebs \
        -var bce_host_audio=none \
        -var bce_user=ubuntu \
	-var use_saved_pkg_src=$(USE_SAVED_PKG_SRC) \
	-var pkg_src_file=$(PKG_SRC_FILE) \
		$(JSON) 2>&1 | tee packer-$@.log 

azure:
	packer build -only=azure \
        -var bce_host_audio=none \
        -var bce_user=packer \
	-var use_saved_pkg_src=$(USE_SAVED_PKG_SRC) \
	-var pkg_src_file=$(PKG_SRC_FILE) \
		$(JSON) 2>&1 | tee packer-$@.log

vbox:
	PACKER_LOG=1 PACKER_LOG_PATH=packer.log \
	packer build -only=virtualbox-iso \
        -var bce_host_audio=$(BCE_HOST_AUDIO) \
	-var use_saved_pkg_src=$(USE_SAVED_PKG_SRC) \
	-var pkg_src_file=$(PKG_SRC_FILE) \
        -var bce_user=oski \
		$(JSON) 2>&1 | tee packer-$@.log

clean:
	rm -rf build packer-*.log packer.log

distclean: clean
	rm -rf packer_cache
