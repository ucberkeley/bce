#!/bin/bash

# This requires that bootstrap.d be entered as a file provisioner in
# the packer json file.

for s in /tmp/bootstrap.d/[0-9][0-9]-* ; do
	echo "BCE: Sourcing bootstrap.d script '${s}'."
	. $s
done
