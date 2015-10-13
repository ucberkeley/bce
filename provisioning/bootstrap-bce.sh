#!/bin/bash

# This requires that bootstrap.d be entered as a file provisioner in
# the packer json file.

## Import debconf.selections for automatic building (rather than passing as kernel boot parameters)
## Apparently running this command in the Dockerfile instead of here has no effect..
#debconf-set-selections < debconf.selections

for s in /tmp/bootstrap.d/[0-9][0-9]-* ; do
	echo "BCE: Sourcing bootstrap.d script '${s}'."
	. $s
done
