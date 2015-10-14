FROM ubuntu:15.04
MAINTAINER Carl Boettiger <cboettig@gmail.com>

## Set environment
ENV TERM xterm
ENV BCE_USER oski
ENV BCE_VERSION 2015-fall

## Set Locales
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

## Create user
RUN useradd $BCE_USER && \
	mkdir /home/$BCE_USER \
	&& chown $BCE_USER:$BCE_USER /home/$BCE_USER


## Install BCE
COPY . /tmp
COPY dot-config /home/$BCE_USER/.config
COPY dot-local /home/$BCE_USER/.local
COPY plymouth-theme /tmp/bce
COPY guest-scripts/setup_ipython_notebook.sh /home/$BCE_USER/setup_ipython_notebook.sh
COPY guest-scripts/update-bce-docs /tmp/update-bce-docs
RUN cd /tmp && \
	DEBIAN_FRONTEND=noninteractive && DEBIAN_PRIORITY=high \
	apt-get update -qq && apt-get install -yq --no-install-recommends \
		apt-transport-https \
		ca-certificates \
		debconf-utils \
		etckeeper \
		lsb-release \
		nano \
		sudo && \
	bzr whoami "Oski Bear <oski@berkeley.edu>" && \
	debconf-set-selections < debconf.selections && \
	bash /tmp/bootstrap-bce.sh 


## Consider: adding jupyter and rstudio-server to path
## Extending with more R packages

EXPOSE 8888
EXPOSE 8787

