## About

It's a small linux distro with zabbix, postgresql, builded as firmware: not changeble system image file with restorable configurations. Simple to use, small-size.
Used build-system is Buildroot.

Build for admins, who need zabbix without big work (for example, windows admins and linux beginners).

Cross-platform, can work in some ARM singe-board computers such asus tinker board and beaglebone black. Also avaible qemu_x86_64.

System can monitoring temperature by external USB-thermometr(see Thermal control part)

Using the buildroot build system allows you to create customized solutions that can be operated by personnel with minimal knowledge of the Linux operating systems. This system is friendly to beginners, but at the same time gives ample opportunities for customization for an experienced developer. It is perfect for solving the problem of inexpensive, but full-featured monitoring of it infrastructure, minimally demanding to the training of its operating personnel.

It is a firmware packaged in a single sdcard.img file. Enough dd utility to fill it on the media.
During loading, file access is expanded, services are downloaded. As a result, you can get a hardware-software monitoring complex that can be ported to the desired architecture.

##Thermal control
System can monitor temperature with RODOS 5 (https://silines.ru/rodos-5s)
If divece inserted in USB-port, you can monitor temperature by zabbix. To do this, you shoud create new data item in Zabbix:

- name - as you wish
- Type - zabbix  agent
- Key - vfs.file.contents[/tmp/rodos_current_temp]
- Type- numeric
- Units - C
- New upplication - server Room Temp

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
3. Go to extracted directory
cd buildroot-2019.05/
4. build image
```bash
make 
```
5. Write image do drive:
```bash
dd if=output/images/sdcard.img of=/dev/sdb && sync
```
## Work instructions
1. boot from writed drive
0. wait for "Ready to work" issue
3. work

## Impotant things
There are 2 partitions on microsd card - with system files and data 
First partition only for bootloader and system!
Every reboot removes all changes on / filesystem!
Second partition(monitorData) for changeble configs and zabbix-database dump.
On first boot system will resize data-partition to all free space

Network settings stored in {monitorData}/wired.network with systemd-networkd format.
Zabbix agent and server config stored on {monitorData} partition
All this configs are  restored on boot! If you need to change them, you mush change then on microsd and then reboot device

If no config files finded on boot, system will use default build-in configs. 

Zabbix database stored in RAM. Every boot system restore database from microsd files, using last dump( called zabbixFullDump{timestamp_of_dump}.sql
If no dump finded, system will use defauls zabbix dump's for fresh-installed system
Every 15 minutes and every shutdown system make new dump.

Default user-pass for ssh and console is root:admin
Dedault zabbix web-interface credentials is Adminx:zabbix


## Board-specific info

### Asus tinker board
Always boot from miscosd card

### Asus tinker board S
Read instructions here: https://tinkerboarding.co.uk/wiki/index.php/Setup#Boot_Priority

### Beaglebone black
Hold down the USER/BOOT button and apply power 
OR 
remove bootloader from build-im emmc( https://www.erdahl.io/2016/12/beaglebone-black-booting-from-sd-by.html )

### QEMU x86_64
```bash
qemu-system-x86_64 -m 2048 -smp 4 -drive file=output/images/sdcard.img,if=virtio,format=raw --enable-kvm -nic bridge,br=bridge0,model=virtio
```
This command will run system with 4 cpu, 2048 RAM, enabled KVM, virtio-net device bridged to real NIC.