#!/bin/bash

# template for starting up a BCE-based EC2 cluster

# you'll need a starcluster config file (see starcluster_example.config as example)
# save your config file as ~/.starcluster/config

# start cluster
starcluster start -c bce mycluster

# add some basic functionality on the master node, tailoring BCE for AWS
starcluster put mycluster modify-for-aws.sh .
starcluster sshmaster mycluster bash modify-for-aws.sh

# add parallel tools to the master node
starcluster put -u oski mycluster add-parallel-tools-2015-spring.sh .
starcluster sshmaster -u oski mycluster sudo bash add-parallel-tools-2015-spring.sh 

# add parallel tools to the worker nodes
starcluster put -u oski mycluster add-parallel-starcluster.sh .
starcluster sshmaster -u oski mycluster sudo bash add-parallel-starcluster.sh 

