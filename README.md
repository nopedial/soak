## SOAK

a lightweight ARP sponge.

## requirements

+ ruby 1.9.3+
+ packetfu 1.1.10+
+ asetus 0.0.7+
+ logger 1.2.8+

# install

	> gem build soak.gemspec
	> gem install ./soak
	>

## usage

	> soakd
 	>

## files

+ configuration file: /etc/soak/config

## configuration example

	{ "interface" : "ethX",
	  "local_mac" : "xx:xx:xx:xx:xx:xx",
	  "sponge" : [ '192.168.0.100', '192.168.0.44', '192.168.0.137' ],
	  "debug" : true }



