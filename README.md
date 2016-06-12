## SOAK [![Gem Version](https://badge.fury.io/rb/soak.svg)](http://badge.fury.io/rb/soak)

lightweight ARP sponge.

## requirements

+ ruby 1.9.3
+ asetus 0.1.2
+ logger 1.2.8

soakd requires root privileges to run.

# install

```
	> gem install soak
	>
```

## usage

```
	> soakd
 	>
```

## files

the configuration file is generated during the first run at: /root/.config/soak/config

## configuration example

```
	---
	interface: eth0
	sponge: [ '192.0.2.44+ff:ff:ff:ff:ff:ff', '192.0.2.45+ee:ee:ee:ee:ee:ee', ]
	debug: true
```


