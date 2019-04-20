<img src="http://cubro.org/images/EXA8_Banner.jpg" width=500>


# EXA8
### Storage
The EXA8 Provides several internal and external storage options, with built-in USB and SDCard slots.

*Please check and confirm the actual device name before proceeding!*

#### SD-MMC
```
mount /dev/mmcblk0p2 /mnt/mmvblk0p2
```
#### USB
```
mount /dev/sdb1 /mnt/sdb1
```

----------

### Root Filesystem
*Please check and confirm the actual device name before proceeding!*


##### Backup OS
Create your own `rootfs` tgz image as follows:
```
mount /dev/mmcblk1p2 /mnt/rootfs
cd /mnt/rootfs
tar vczf /rootfs.tgz *
```
##### Restore OS
Deploy `rootfs` to ext4 partition *(will destroy all data!)*
```
mkfs.ext4 /dev/mmcblk1p2
mount /dev/mmcblk1p2 /mnt/rootfs
tar -xvf taskit-rootfs.tar -C /mnt/rootfs
```

----------

### U-Boot
The EXA8 SOC is powered by U-Boot and can easily be managed throught console port.

*NOTE: The Boot procedure and init procedures can be stopped only through console!*

#### Boot from MMC
To temporarily boot your OS from MMC w/o saving settings, use the following example:
```
setenv bootargs "bootargs=console=ttyAMA0,115200n8 earlycon=pl011,0x87e028000000 debug maxcpus=4 rootwait rw root=/dev/mmcblk0p2 coherent_pool=16M"
boot
```
#### Boot from USB
To temporarily boot your OS from USB w/o saving settings, use the following example:
```
setenv bootargs "bootargs=console=ttyAMA0,115200n8 earlycon=pl011,0x87e028000000 debug maxcpus=4 rootwait rw root=/dev/sda2 coherent_pool=16M"
boot
```

