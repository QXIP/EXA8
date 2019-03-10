<img src="http://cubro.org/images/EXA8_Banner.jpg" width=500>

# CURBO EXA8
## QXIP Open-Source
QXIP maintains and distributes ubuntu:xenial packages for the [EXA8](http://cubro.org) [ARM64](https://github.com/lmangani/EXA8/blob/master/hardware.md) platform through its repositories, including:

#### Applications
* `HEPlify`, `HEPlify-Server`
* `HEPAgent`, `CaptAgent`
* `ngrep`
* `tshark`
#### Libraries
* `peaFowl`
* `libUV`
* `libzmq`
* `libnuma`

-----------

### Repository Installation
SSH to your EXA8 Unit, execute the following command as `root`:
```
curl -s https://packagecloud.io/install/repositories/qxip/cubro-pub/script.deb.sh | sudo bash
```

### Repository Usage
Once the QXIP repository is installed, packages can be installed with `apt`
```
apt update
apt install heplify
```
