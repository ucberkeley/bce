#!/bin/bash

# We currently set BCE_PROVISION from the shell / Packer as a demonstration of
# how we might modify execution of this script. But for now, we are not using
# this value.

START_TIME=$(date '+%s')

# apt in general is probably too verbose for our useage - it's hard to detect
# where actual failures may have occurred. Maybe we can reduce verbosity?
APT_GET="apt-get -q -y"
# APT_GET="apt-get -qq -y"

if [ "${PACKER_BUILDER_TYPE}" == "amazon-ebs" ]; then
    msg="BCE: waiting for cloud-init to finish..."
    echo $msg
    while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done
    echo DONE: $msg
fi

msg="BCE: Updating apt cache..."
echo $msg
$APT_GET update > /dev/null && \
echo DONE: $msg || echo FAIL: $msg

msg="BCE: configure etckeeper with git..."
echo $msg
# Track system changes
$APT_GET install git etckeeper && \
sed -i -e '/^VCS/s/^/#/' -e '/="git"/s/^#//' /etc/etckeeper/etckeeper.conf && \
cd /etc && \
# XXX - after we're done being the BCE provisioner, should we disable this
# config? i.e., at the end of this script?
git config --global user.name "BCE provisioner" && \
git config --global user.email "bce@lists.berkeley.edu" && \
etckeeper init && \
echo DONE: $msg || echo FAIL: $msg

echo "BCE: Installing build utilities..."
# This is more robust - redundancy is not a problem!
$APT_GET install build-essential dkms xserver-xorg dmidecode curl \
    software-properties-common && \
echo DONE: $msg || echo FAIL: $msg

# An alternative method would be to manually share the directory on the host
# which actually contains VBoxGuestAdditions.iso. On a Mac that is
# /Applications/VirtualBox.app/Contents/MacOS/. Just like with the host user's
# home directory however, there's no convenient variable representing this
# location within the Shared Folders configuration.

# There's also a `vboxmanage guestcontrol updateadditions` command,
# but that doesn't seem to work from within Packer.

if [ "${PACKER_BUILDER_TYPE}" == "virtualbox-iso" ]; then
    msg="BCE: Installing Guest Additions..."
    echo "$msg"
    # Currently, we attach the Guest additions iso when using Packer.
    # The guest extensions end up as a second CD/DVD drive
    # (/dev/cdrom (aka /dev/sr0) is the Ubuntu ISO)
    mount /dev/sr1 /mnt && \
    /mnt/VBoxLinuxAdditions.run -- --force
    # XXX We break logical chaining here, because it's never working!
    eject /mnt && \
    ( echo DONE: $msg ; etckeeper commit "$msg" ) || echo FAIL: $msg
    #echo DONE: $msg || echo "FAIL (but not really?):" $msg
fi

# CRAN repo
# There was no 14.04 CRAN archive yet so it is commented out
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
#echo "#deb http://cran.cnr.berkeley.edu/bin/linux/ubuntu trusty/" > \
#    /etc/apt/sources.list.d/cran.list && \


# XXX -  we are not currently installing R packages with apt
# # apt-add-repository is included in software-properties-common which is
# # installed in the "Installing build utilities" step.
# msg="BCE: Installing R PPAs..." echo "$msg"
# # Prefer rrutter and c2d4u PPAs
# apt-add-repository -y ppa:marutter/rrutter && \
# apt-add-repository -y ppa:marutter/c2d4u && \
# ( echo DONE: $msg ; etckeeper commit "$msg" ) || echo FAIL: $msg

msg="BCE: Installing Ubuntu packages..."
echo "$msg"
# This ensures we get security updates, etc.
# Note that this is ALSO done currently by the debian-installer step...
$APT_GET dist-upgrade && \
# The grep bit allows us to have comments in the packages file
# We install no-recommends first, to avoid them getting pulled in by the other
# installs
$APT_GET install --no-install-recommends \
    $(grep '^[^#]' /tmp/packages/ubuntu-packages-norecommends.txt) && \
$APT_GET install $(grep '^[^#]' /tmp/packages/ubuntu-packages.txt) && \
$APT_GET clean && \ # help avoid running out of disk space
echo DONE: $msg  || echo FAIL: $msg

msg="BCE: Setting Xfce4 as default X session"
echo "$msg"
update-alternatives --set x-session-manager /usr/bin/xfce4-session && \
( echo DONE: $msg ; etckeeper commit "$msg" ) || echo FAIL: $msg

msg="BCE: Hide boot messages"
echo "$msg"
sed -i \
	-e '/GRUB_HIDDEN_TIMEOUT=/ s/^#//' \
	-e '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/".*"/"quiet splash"/' \
	/etc/default/grub && \
( echo DONE: $msg ; etckeeper commit "$msg" ) || echo FAIL: $msg

msg="BCE: Disable sudo password for those in the sudo group"
echo "$msg"
printf "%%sudo\tALL=(ALL:ALL) NOPASSWD: ALL\n" > /etc/sudoers.d/nopasswd && \
( echo DONE: $msg ; etckeeper commit "$msg" ) || echo FAIL: $msg

# XXX - we should also set sensible defaults for gedit
msg="BCE: Set a 4-space tabstop for nano"
echo "$msg"
sed -i -e '/# set tabsize 8/s/.*/set tabsize 4/' /etc/nanorc && \
( echo DONE: $msg ; etckeeper commit "$msg" ) || echo FAIL: $msg

msg="BCE: Create (or configure) oski user"
echo "$msg"
(
  if [ "${PACKER_BUILDER_TYPE}" == "virtualbox-iso" ]; then
    # oski is created in the debian-installer phase
    adduser oski vboxsf
  else
    # Avoid interactive prompts in user creation
    adduser --disabled-password --gecos "" oski && \
    echo oski:oski | chpasswd
  fi && \
  # Enable oski to login without a password
  adduser oski nopasswdlogin
) && \
( echo DONE: $msg ; etckeeper commit "$msg" ) || echo FAIL: $msg

msg="BCE: Configure oski (and other) desktops"
echo "$msg"
# Create a convenient place on the desktop for people to mount
# their Shared Directories.
if [ "${PACKER_BUILDER_TYPE}" == "amazon-ebs" ]; then
    # We are initially copying files to the (pre-existing) ubuntu user
    cp -r /home/ubuntu/.config /home/oski/.config && \
    chmod 755 /home/ubuntu/setup_ipython_notebook.sh && \
    cp /home/ubuntu/setup_ipython_notebook.sh /home/oski && \
    chown -R oski:oski /home/oski
else
    chmod 755 /home/oski/setup_ipython_notebook.sh
fi && \

# XXX - This may also be appropriate for VMware
# This provides obvious access to shared folders in VBox
if [ "${PACKER_BUILDER_TYPE}" == "virtualbox-iso" ]; then
  sudo -u oski mkdir /home/oski/Desktop && \
  sudo -u oski ln -s /media /home/oski/Desktop/Shared
fi && \

echo DONE: $msg || echo FAIL: $msg

# Automatically login oski at boot
# XXX - Is there a way to get oski listed in the login screen (it displays guest
# user if you log out)

if [ "${PACKER_BUILDER_TYPE}" == "virtualbox-iso" ]; then
    msg="BCE: Automatically login oski at boot"
    echo "$msg"
    printf "[SeatDefaults]\nautologin-user=oski\nautologin-user-timeout=0\n" >> \
	/etc/lightdm/lightdm.conf.d/20-BCE.conf && \
	#/usr/lib/lightdm/lightdm-set-defaults --autologin oski
    echo DONE: $msg || echo FAIL: $msg
fi



# Google Chrome
msg="BCE: Installing google chrome..."
echo "$msg"
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > \
    /etc/apt/sources.list.d/google-chrome.list && \
curl -L https://dl-ssl.google.com/linux/linux_signing_key.pub | \
    apt-key add - && \
$APT_GET update > /dev/null && \
$APT_GET install google-chrome-stable && \
echo DONE: $msg  || echo FAIL: $msg

# R, RStudio
msg="BCE: Installing RStudio..."
echo "$msg"
RSTUDIO_URL=http://download1.rstudio.org/rstudio-0.98.953-amd64.deb

curl -L -O ${RSTUDIO_URL} && \
dpkg -i $(basename ${RSTUDIO_URL}) && \
( echo DONE: $msg ; etckeeper commit "$msg" ) || echo FAIL: $msg

msg="BCE: Installing add-on R packages..."
echo "$msg"
Rscript -e "pkgs <- scan('/tmp/packages/R-packages.txt', what = 'character'); \
install.packages(pkgs, repos = 'http://cran.cnr.berkeley.edu')" && \
echo DONE: $msg || echo FAIL: $msg

# Python stuff
msg="BCE: Downloading PyCharm to /opt"
echo "$msg"
PYCHARM_URL=http://download.jetbrains.com/python/pycharm-community-3.4.1.tar.gz
curl -L -O ${PYCHARM_URL} && \
tar -C /opt -xzf pycharm-community-*.tar.gz && \
chown oski:oski /opt/pycharm-community-* && \
rm pycharm-community-*.tar.gz && \
echo DONE: $msg || echo FAIL: $msg

msg="BCE: Installing Python modules..."
echo "$msg"
# We install pip directly from pypa to avoid conflicts with requests
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && \
python /tmp/get-pip.py && \
pip install --upgrade -r /tmp/packages/python-requirements.txt && \
echo DONE: $msg || echo FAIL: $msg
# Note, pip won't change /etc

# Clean up the image before we export it
$APT_GET clean
END_TIME=$(date '+%s')

ELAPSED_SECS=$((END_TIME-START_TIME))
printf "Elapsed time: %s minutes\n" $((ELAPSED_SECS/60))
