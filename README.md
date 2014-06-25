## SOAK

a lightweight ARP sponge.

## requirements

+ ruby 1.9.3+
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

the configuration file is generated during the first run at: /root/.config/soak/config

## configuration example

	---
	interface: eth0
	local_mac: ff:ff:ff:ff:ff:ff
	sponge: [ '192.168.0.44', '192.168.0.100' ]
	debug: true


