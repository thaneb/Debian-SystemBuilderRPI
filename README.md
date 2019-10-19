# Debian-SystemBuilderRPI for noobs or lazy users ^^
Script to (almost) auto build a debian system on a raspberry pi external drive

### For now, this script will help you to build a debian system "buster" arm64 to a pre-formatted (at least 2 partitions)
# usb drive connected to your raspberry pi. The script will be updated as soon as possible to be easier and configurable.
# Until I make it much more configurable, this script is targetting the RPI4 (as it's still not able to natively usb boot).
##
# Let's say you have a running system on a sdcard flashed with DietPi, Raspbian, Debian, -buntu or Kali, and only 1 usb drive connected.
# Using gparted :
# remove all partitions from the drive (UNDERSTAND = LOSING ALL DATA STORED ON IT)
# create 2 partitions on the drive (the formatting command order is essential for the script to work) :
# format the 1st (120 to 200mg) as fat32 or fat16 , it should identified by gparted as sda1 .
# THEN format the 2nd (at least 1Gb) as ext4 , it should identified by gparted as sda2 .
# You can keep some free drive space or create one or more others partitions (exfat is a great filesystem as it can be read/write natively
# by macos, windows, or linux ( sudo apt-get install exfat-fuse exfat-utils ), to format partitions from a debian like desktop environment, 
# you need : sudo apt-get install exfat-fuse exfat-utils gnome-disk-utility , and then use the " drive " app).
##
# IMPORTANT :
# HAVE ONLY the targeted drive connected on usb, having another drive may lead to issue.
# The 1st partition (sda1) will not be use for now, but it will usefull and easier to already have it when the rpi4 will be able
# to natively boot from usb.
# SO IT MEANS THE /BOOT (first partition of your sdcard) will be use to boot on the usb drive, you may want to make a copy of its content
# somewhere else if you made your own modifications to its files or if you want to boot again on the sdcard partition 2 system.
# NB : we make a copy of the /boot before deleting it, the copy will be available on the new system at /root/oldbootp 
##
# Just copy past all this code in a terminal of the rpi (can be done through ssh of course) and press enter.
# Your command prompt should then display "chmod +x buildbuster.sh", press enter again and then type " sudo ./buildbuster.sh "
# This will start to create the debian buster arm64 system on sda2 (the 2nd partition of your usb drive).
# When this part will ended, you will be already "chrooted" in your future system
# (let's say it's a you will be looged as root in your future system)
# you can check you are at this step easily, if the " ls " command show you the file named " buildcontinue.sh ", it seems everything ok !
# from here, just type in ./buildcontinue.sh and press enter
