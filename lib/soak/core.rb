module Soak

  require 'logger'
  target = STDOUT
  Log = Logger.new target

  # import user configuration
  require 'asetus'
  if File.exists? '/etc/soak/config'
    Cfg  			= Asetus.cfg name: 'soak'
  else
    CFG = Asetus.new :name=>'soak', :load=>false
    CFG.default.interface 	= 'eth0'
    CFG.default.local_mac 	= 'ff:ff:ff:ff:ff:ff'
    CFG.default.sponge 		= []
    CFG.default.debug 		= false
    CFG.load
    if CFG.create
      CFG.save
      puts "+ edit: '/root/.config/soak/config'"
      exit 0
    else
      Cfg = CFG.cfg
    end
  end
  Process.daemon if not Cfg.debug

  # constants
  ETH_P_ALL     =  0x03_00
  SIOCGIFINDEX  =  0x89_33
  PF_PACKET     =  17
  AF_PACKET     =  PF_PACKET
  IFREQ		=  [ Cfg.interface.dup ].pack 'a32'
  RawSocket     =  Socket.open Socket::PF_PACKET, Socket::SOCK_RAW, ETH_P_ALL

  # setup sending device
  RawSocket.ioctl(SIOCGIFINDEX, IFREQ)
  RawSocket.bind [AF_PACKET].pack('s') + [ETH_P_ALL].pack('n') + IFREQ[16..20] + ("\x00" * 12)

end
