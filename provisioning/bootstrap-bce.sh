#!/bin/bash

# These depend on bootstrap.d to be entered as a file provisioner in the json

for s in /tmp/bootstrap.d/[0-9][0-9]-* ; do
	echo "BCE: Sourcing bootstrap.d script '${s}'."
	. $s
done
