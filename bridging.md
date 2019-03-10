<img src="http://cubro.org/images/EXA8_Banner.jpg" width=500>


# EXA8 BRIDGE

## SWITCH MODES
The Cubro EXA8 ships with the flagship sub-millisecond passive Bridge, vertically linking all interface pairs by default.

*NOTE: When running in BYPASS mode, no packets will be visible by the integrated platform!*


#### Enable/Disable Bypass Mode
The interface for each pair are controlled by dedicated GPIO pins

##### EXA8 Pin Layout
```
ge5 ~ ge6 (pin 32);
ge7 ~ ge8 (pin 33);
ge1 ~ ge2 (pin 34);
ge3 ~ ge4 (pin 35);
```

###### Enable Bypass Mode
```
gpioset <gpio_pin> set 0
```

###### Disable Bypass Mode
```
gpioset <gpio_pin> set 1
```


## ACTIVE
When BYPASS mode is disabled, the integrated system can be configured to handle packets.

The following examples illustrates a simple bridge between interfaces `lan1` and `lan2` with sniffing capabilities

*NOTE: Any interface and GPIO changes should be applied on each boot to avoid bypass default mode!* 

###### Create a veth and br pair
```
ip link add veth0 type veth peer name veth1
brctl addbr br0
brctl addbr br1
```

###### Pair interfaces with bridges
```
brctl addif br0 lan1
brctl addif br0 veth0
brctl addif br1 lan2
brctl addif br1 veth1
```
###### Activate Interfaces
```
ifconfig veth0 up
ifconfig veth1 up
ifconfig lan1 up
ifconfig lan2 up
ifconfig br0 up
ifconfig br1 up
```
