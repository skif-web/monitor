## About

It's a small linux distro with zabbix, postgresql, builded as firmware: not changeble system image file with restorable configurations. Simple to use, small-size.
Used build-system is Buildroot

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
This command will run system with 4 cpu, 2048 RAM, enabled KVM, virtio-net device bridget to real NIC.