
## Help yourself, take 3 minutes to read the readme !!!
 
rm buildbuster.sh
cat <<BBuster > buildbuster.sh
#!/bin/bash
# Installing required packages
echo 'Installing required packages'
apt -y install arch-test debootstrap

# Create mount point
echo 'Create mount point'
mkdir /mnt/debootstraparm64

# Mounting partitions of the ONLY ONE EXTERNAL DRIVE CONNECTED (should be sda) and binding required folders for the chroot to come
echo 'Mounting the external drive futur system partition (should be sda1) and binding required folders for the chroot to come'
mount /dev/sda2 /mnt/debootstraparm64
mkdir /mnt/debootstraparm64/boot
mount /dev/mmcblk0p1 /mnt/debootstraparm64/boot
mount -i -o remount,exec,dev /mnt/debootstraparm64
debootstrap --arch=arm64 buster /mnt/debootstraparm64
mount -o bind /proc /mnt/debootstraparm64/proc
mount -o bind /sys /mnt/debootstraparm64/sys
mount -o bind /dev /mnt/debootstraparm64/dev
mount -o bind /dev/pts /mnt/debootstraparm64/dev/pts
cp /etc/resolv.conf /mnt/debootstraparm64/etc/resolv.conf

## Creating the target fstab
echo 'creating the target fstab'
cat <<PM > /mnt/debootstraparm64/etc/fstab
#----------------------------------------------------------------
# INTERNAL SYSTEM PHYSICAL DRIVES
#----------------------------------------------------------------
PARTUUID=/dev/sda2        /               ext4	noatime,lazytime		0 1
PARTUUID=/dev/mmcblk0p1   /boot           vfat	noatime,lazytime		0 1
PARTUUID=/dev/mmcblk0p2   /media/sdcard2	ext4	noatime,nofail,lazytime		0 1
PM

# Creating the script that will manage install in chroot environment
echo 'Creating the script that will manage install in chroot environment'

cat <<BC > /mnt/debootstraparm64/buildcontinue.sh
#!/bin/bash

echo "deb http://deb.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list
echo "deb http://deb.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list
#echo "deb-src http://deb.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list
#echo "deb-src http://deb.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list
#echo "deb-src http://deb.debian.org/debian buster-updates main contrib non-free" >> /etc/apt/sources.list
apt-get update

# Install essentials packages
echo 'Install essentials packages'
apt -y install ca-certificates dbus sudo git unzip wget zip
service dbus restart
apt -y install wpasupplicant wireless-tools firmware-atheros firmware-brcm80211 firmware-misc-nonfree firmware-realtek dhcpcd5 net-tools curl

# Installing WiFi firmwares
echo 'Installing WiFi firmwares'
mkdir wifi-firmware
cd wifi-firmware
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43455-sdio.bin
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43455-sdio.clm_blob
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43455-sdio.txt 
cp *sdio* /lib/firmware/brcm/
cd ..
rm -rf wifi-firmware

# Set the future system name
echo 'Set the future system name " Debian " '
echo "Debian" > /etc/hostname

# Backing up the /boot to /root/oldbootp and clean /boot
mkdir /root/oldbootp
cp /boot/* /root/oldbootp/
rm -rf /boot/*

# Installing kernels and modules
echo 'Installing kernels and modules'
git clone --depth 1 https://github.com/raspberrypi/firmware
cp -r firmware/boot/* /boot/
mkdir /lib/modules
cp -r firmware/modules/* /lib/modules/
rm -rf firmware

# Enabling essential OS services
echo 'Enabling essential OS services'
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service

# Creating the /boot/cmdline.txt targeting the external drive as system to boot 
echo 'Creating the /boot/cmdline.txt targeting the external drive as system to boot'
echo "dwc_otg.fiq_fix_enable=2 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/sda2 rootfstype=ext4 rootwait rootflags=noload net.ifnames=0" > /boot/cmdline.txt

# Creating the /boot/config.txt
echo 'Creating the /boot/config.txt'
cat <<CFT > /boot/config.txt
# For more options and information see
# http://rpf.io/configtxt
# Some settings may impact device functionality. See link above for details

# uncomment if you get no picture on HDMI for a default "safe" mode
#hdmi_safe=1

# uncomment this if your display has a black border of unused pixels visible
# and your display can output without overscan
#disable_overscan=1

# uncomment the following to adjust overscan. Use positive numbers if console
# goes off screen, and negative if there is too much border
#overscan_left=16
#overscan_right=16
#overscan_top=16
#overscan_bottom=16

# uncomment to force a console size. By default it will be display's size minus
# overscan.
#framebuffer_width=1280
#framebuffer_height=720

# uncomment if hdmi display is not detected and composite is being output
#hdmi_force_hotplug=1

# uncomment to force a specific HDMI mode (this will force VGA)
#hdmi_group=1
#hdmi_mode=1

# uncomment to force a HDMI mode rather than DVI. This can make audio work in
# DMT (computer monitor) modes
#hdmi_drive=2

# uncomment to increase signal to HDMI, if you have interference, blanking, or
# no display
#config_hdmi_boost=4

# uncomment for composite PAL
#sdtv_mode=2

#uncomment to overclock the arm. 700 MHz is the default.
#arm_freq=800

# Uncomment some or all of these to enable the optional hardware interfaces
#dtparam=i2c_arm=on
#dtparam=i2s=on
#dtparam=spi=on

# Uncomment this to enable the lirc-rpi module
#dtoverlay=lirc-rpi

# Additional overlays and parameters are documented /boot/overlays/README

# Enable audio (loads snd_bcm2835)
dtparam=audio=on

#[pi4]
# Enable DRM VC4 V3D driver on top of the dispmanx display stack
#dtoverlay=vc4-fkms-v3d
#max_framebuffers=2
gpu_mem=256

# If you would like to enable USB booting on your Pi, uncomment the following line.
# Boot from microsd card with it, then reboot.
# Don't forget to comment this back out after using, especially if you plan to use
# sdcard with multiple machines!
# NOTE: This ONLY works with the Raspberry Pi 3+
#program_usb_boot_mode=1

#[pi4]
# 64bit kernel for Raspberry Pi 4 is called kernel8 (armv8a)
kernel=kernel8.img

# Tell firmware to go 64bit mode.
arm_64bit=1
CFT

# Adding sudoer user " debian " and requesting its password
echo 'Creating a sudoer user named "debian", please enter its password :'
adduser debian
usermod -aG sudo debian

# Installing dropbear for light and easy ssh access to the future system and clean the bash and the system
echo 'Installing dropbear for light and easy ssh access to the future system and clean the bash and the system'
apt-get -y install dropbear
apt-get -y upgrade
apt -y autoremove
apt autoclean
history -c
exit
BC

# Give execute permission to the script to execute in chroot environment
chmod +x /mnt/debootstraparm64/buildcontinue.sh

# Go chroot
echo 'We go chroot, please type in " ./buildcontinue.sh " and then press Enter'
chroot /mnt/debootstraparm64

# Clean the chroot install script
echo 'Clean the chroot install script'
rm /mnt/debootstraparm64/buildcontinue.sh

# Unbinding chroot required folders
echo 'Unbinding chroot required folders'
umount /mnt/debootstraparm64/boot
umount /mnt/debootstraparm64/proc
umount /mnt/debootstraparm64/sys
umount /mnt/debootstraparm64/dev/pts

# Unmounting the future drive partitions
echo 'Unmounting the future drive partitions'
umount -lf /mnt/debootstraparm64/dev
umount -lf /mnt/debootstraparm64

# Remove the mount point
echo 'Remove the mount point'
rm /mnt/debootstraparm64

# Clean the script
echo 'Clean the script'
rm buildbuster.sh

#Everything finished ;-)
echo 'Everything finished ;-) reboot to start your new debian arm64 system on usb drive'
BBuster
echo 'just press enter to the following command "chmod +x buildbuster.sh" '
chmod +x buildbuster.sh
