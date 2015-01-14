Overview
=============================

Both approaches outlined below will retrieve a minimal Ubuntu box and provision it utilizing the bootstrap-bce.sh script. The BCE\_PROVISION environment variable serves as a hint to the bootstrap script so that different authors can create different VMs using the same build framework.

Note that to create a VM for VirtualBox, you'll need a recent version of VirtualBox (in particular the default version on Ubuntu 12.04 is too old - you'll need to install the Ubuntu virtualbox-4.3 package). 

Requirements
=============================
* Packer - installation instructions are at https://www.packer.io/intro/getting-started/setup.html

Creating BCE VMs with Packer
=============================

For a Virtualbox VM, run:

    $ make vbox

This creates a virtual machine in the OVA format that can be imported into Virtualbox on Windows, Mac, or UNIX.

To create an Amazon EC2 AMI, set your Amazon security credentials and then run:

    $ make ec2

Amazon credentials can be set on the command line or by editing the BCE json file. To set on the command line run:

    $ export AWS_ACCESS_KEY_ID=YYY
    $ export AWS_SECRET_ACCESS_KEY=ZZZ

More information on building to ec2 is available on the [packer ec2 help page](https://www.packer.io/docs/builders/amazon-ebs.html)

Note that currently when you start up a VM from the resulting AMI, you'll need to first login as the 'ubuntu' user and set up SSH keys for the 'oski' user, which is the user provisioned by BCE.

Notes/TODO on provisioning
==========================

I'm still having trouble using the guest additions that are already available
from the VirtualBox install.

Note that it should be possible to attach the bundled ISO for guest additions
using something like the following in the JSON "vboxmanage" section:

```json
[
  "storageattach",   "{{.Name}}",
  "--storagectl",    "IDE Controller",
  "--port",          "1",
  "--device",        "0",
  "--type",          "dvddrive",
  "--medium",        "additions"
]
```

For which you should also switch "guest_additions_mode" to "disable."

But for some reason, I get the complaint:

    VBoxManage: error: Invalid UUID or filename "additions"

Strangely, this DOES work if I execute it during provisioning:

    vboxmanage storageattach "BCE-xubuntu-14.04-amd64" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium additions

Go figure
