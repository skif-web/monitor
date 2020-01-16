# Monitor linux

## About

It's a small linux distro with zabbix, postgresql, builded as firmware: not changeble system image file with restorable configurations. Simple to use, small-size.
Used build-system is Buildroot.

Build for admins, who need zabbix without big work.

Cross-platform, can work in some ARM singe-board computers such rasberri pi 4,asus tinker board and beaglebone black. Also avaible qemu_x86_64.

System can monitoring temperature by external USB-thermometr(see Thermal control part)

Using the buildroot build system allows you to create customized solutions that can be operated by personnel with minimal knowledge of the Linux operating systems. This system is friendly to beginners, but at the same time gives ample opportunities for customization for an experienced developer. It is perfect for solving the problem of inexpensive, but full-featured monitoring of it infrastructure, minimally demanding to the training of its operating personnel.

It is a firmware packaged in a single sdcard.img file. Enough dd utility to fill it on the media.
During loading, file access is expanded, services are downloaded. As a result, you can get a hardware-software monitoring complex that can be ported to the desired architecture.

## Download
[Current version 1.0b:] (https://github.com/skif-web/monitor/releases/tag/1.0b)

[All releases:] (https://github.com/skif-web/monitor/releases)

## Thermal control
System can monitor temperature with RODOS 5 (https://silines.ru/rodos-5s)
If device inserted in USB-port, you can monitor temperature by zabbix. To do this, you shoud create new data item in Zabbix:

- name - as you wish
- Type - zabbix  agent
- Key - vfs.file.contents[/tmp/rodos_current_temp]
- Type- numeric
- Units - C
- New upplication - server Room Temp
- 
## Build instructions
1. Clone git
```bash
git clone git@github.com:skif-web/monitor.git
```
2. Run script run_me.sh inside monitor directory , select need arch
```bash
cd monitor
./run_me.sh
```
3. Go to extracted directory. Warning!Dirname depends on buildroot version
cd buildroot-2019.05/
4. build image
```bash
make 
```
5. Write image do drive:
```bash
dd if=output/images/sdcard.img of=/dev/${your_sdcard_device} && sync
```
## Work instructions

1. boot from writed drive
2. wait for "Ready to work" message on display (tty1)
3. work

## Impotant things
There are 2 partitions on microsd card - with system files and data 
First partition only for bootloader and system!
Every reboot removes all changes on / filesystem!
Second partition(monitorData) for changeble configs and zabbix-database(postgresql dir).

On first boot system will resize data-partition to all free space.
Also, first boot. Don't panic.

Default user-pass for ssh and web-console is root:admin
Default zabbix web-interface credentials is Adminx:zabbix

Also see "Using external drive" - part

## Access to system
You can get system IP from local console (see item 2)
Avaible 3 ways:

1. Main method: web-interface. Open http://${ip} and see web-interface
2. Local monitor. You can conect display via microhdmi and keyboard (via usb) and work as normal computer
3. SSH

## Web interface
### General information
Avaible via web-browser by ip.
The are 3 links left-side:

1. Admin panel - web-interface for device manage
2. Zabbix management - Zabbix native web-interface
3. Project site on github - github page of this distro

In right-side you can download pdf-version of this manual.

### Admin panel

Status - show status of system.

Settings - can be user to change timezone, select use or not external  drive, change admin password(also change for tty,web-nterface and ssh).

Backup/Restore/Factory reset - you can download system config and postgresql-dump. Also avaible reverse-operation: enable new settings and restore database from dump. Factory reset clear all settings and remove zabbix database.

---

**NOTE**
Warning! Factory reset destroy ALL data!!!

Restore and Reset operations need reboot after them.

---

Network - you can change hostname, select static or dhcp network interface mode. Supported only one interface.

Halt/Reboot - no comments ;)

Update firmware - upload and enable new version. Need reboot for complete.


## Using external drive
If  used external drive, it will be user for postgresql dir.

By default, external drive disabled and zabbix database stored on second partition.

If you need to move database from sdcard to external drive (or do reverse operation), you MUST use database backup/restore.

---

**NOTE**
Warning! External drive will be formated!All data on this drive will be destroyed!

---
Also, first boot with new external-drive will bw some long. Don't panic.



## Board-specific info

### Asus tinker board
Always boot from miscosd card

### Asus tinker board S
Read instructions here: https://tinkerboarding.co.uk/wiki/index.php/Setup#Boot_Priority

### Beaglebone black
Hold down the USER/BOOT button and apply power 
OR 
remove bootloader from build-im emmc( https://www.erdahl.io/2016/12/beaglebone-black-booting-from-sd-by.html )

### Rasberry pi 4 board
Always boot from miscosd card

### QEMU x86_64

qemu-system-x86_64 -smp 4 -m 4026M -enable-kvm -machine q35,accel=kvm -device intel-iommu -cpu host -net nic -net user,hostfwd=tcp::5555-:80,hostfwd=tcp::4444-:22 -device virtio-scsi-pci,id=scsi0 -drive file=output/images/qemu.qcow2,format=qcow2,aio=threads   -device virtio-scsi-pci,id=scsi1 -drive file=output/images/external.qcow2,format=qcow2,aio=threads

This command will run system with 4 cpu, 4096 RAM, enabled KVM, virtio-net device (with port from 127.0.0.1 forwarding 5555 to web-interface and 4444 to ssh ) and 2 hdd drive: volume with system+configs and second (external) for postgresql files.
