<img src="http://cubro.org/images/EXA8_Banner.jpg" width=500>


# Cubro EXA8
The EXA8 is a compact multi-application device which can be used for aggregation, filtering and capturing of network traffic in real-time powered by an integrated onboard arm64 platform albe to run standard and custom software.

## QXIP + EXA8
QXIP maintains and distributes ubuntu:xenial packages for the EXA8 ARM64 platform through its repositories, including:

* `HEPlify`, `HEPlify-Server`
* `HEPAgent`, `CaptAgent`
* `peaFowl`
* `LibUV`
* `ngrep`
* `tshark`

### Repository Installation
From your EXA8 Unit, execute the following command as `root`:
```
curl -s https://packagecloud.io/install/repositories/qxip/cubro-pub/script.deb.sh | sudo bash
```

### Repository Usage
Once the QXIP repository is installed, packages can be installed with `apt`
```
apt update
apt install heplify
```

## DEV
See [Cross-Compilation and Development](https://github.com/lmangani/EXA8/blob/master/crosscompile.md)
## HARDWARE
See [Hardware Notes](https://github.com/lmangani/EXA8/blob/master/hardware.md)



## Disclaimer
Cubro and EXA8 are trademarks of Cubro. All Rights Reserved.
