starcluster start -c bce -s 1 mycluster

starcluster put mycluster modify-for-aws.sh .
starcluster sshmaster mycluster bash modify-for-aws.sh

starcluster sshmaster mycluster

cd /tmp

INSTALL_DIR=/usr/local/openmpi

MPI_VERSION=1.8.4

wget http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-${MPI_VERSION}.tar.gz

tar -xvzf openmpi-${MPI_VERSION}.tar.gz
cd openmpi-${MPI_VERSION}

mkdir ${INSTALL_DIR}
./configure --prefix /usr/local/openmpi --enable-orterun-prefix-by-default 2>&1 | tee ../configure.log
make all install 2>&1 | tee ../make_all_install.log

cd ${INSTALL_DIR}
tar -cvzf /tmp/bce-openmpi-${MPI_VERSION}.tgz .

# set up code to upload tarball to google drive
