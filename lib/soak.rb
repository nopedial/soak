module Soak
 Directory = File.expand_path File.join File.dirname(__FILE__), '../'
 require 'socket'
 require 'ipaddr'
 require 'thread'
 require 'soak/core'
 require 'soak/lookup'
 require 'soak/packet'
end
