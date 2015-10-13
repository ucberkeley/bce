#!/bin/bash

# This whole script runs as root.

# copy this file to (or paste the contents into) a
# text file called add-parallel-tools.sh on the VM
# run this script as follows: 
#   sudo bash add-parallel-tools.sh
# it will take a couple minutes to complete

export DEBIAN_PRIORITY=high
export DEBIAN_FRONTEND=noninteractive

# install fast linear algebra package and MPI functionality
# we install openMPI from source because Ubuntu-packaged version (1.6.5)
# has bug in MPI_Comm_spawn affecting Rmpi
git config --global user.email "bce@lists.berkeley.edu"
git config --global user.name "BCE Release Team"


MPI_VERSION=1.8.4
mkdir /usr/local/openmpi
cd /usr/local/openmpi
# get openmpi from permanent BCE repository
wget -O bce-openmpi-${MPI_VERSION}.tgz https://googledrive.com/host/0B9npFE3iDymgbTBZUGRBV3VYOEE
# temporary location (should still work if needed)
# wget http://www.stat.berkeley.edu/~paciorek/transfer/bce-openmpi-${MPI_VERSION}.tgz

tar -xvzf bce-openmpi-${MPI_VERSION}.tgz
rm bce-openmpi-${MPI_VERSION}.tgz
echo /usr/local/openmpi/lib > /etc/ld.so.conf.d/openmpi.conf
ldconfig
echo 'export PATH=${PATH}:/usr/local/openmpi/bin' >> /etc/bash.bashrc
export PATH=${PATH}:/usr/local/openmpi/bin

# install parallelization packages for Python
# conda install mpi4py
sudo -u ${BCE_USER} conda install --yes --use-local mpi4py

# conda install pp
# conda pipbuild pp
# pip install --allow-external --allow-unverified pp
# all of the above fail, so use this approach
# currently this approach puts pp in miniconda directory in vbox but not EC2
PP_VERSION=1.6.4
cd /tmp
wget http://www.parallelpython.com/downloads/pp/pp-${PP_VERSION}.tar.gz
tar -xvzf pp-${PP_VERSION}.tar.gz
cd pp-${PP_VERSION}
python setup.py install

# install parallelization packages for R
cat <<EOF > /tmp/R-packages.txt
doMPI
rlecuyer
pbdDEMO
pbdSLAP
pbdBASE
pbdDMAT
pbdMPI
EOF

Rscript -e "pkgs <- scan('/tmp/R-packages.txt', what = 'char'); install.packages(pkgs)"

