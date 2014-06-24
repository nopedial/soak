module Soak

  # import user configuration
  require 'asetus'
  Cfg  		= Asetus.cfg name: 'soak'
  Process.daemon if not Cfg.debug

  # logging
  require 'logger'
  target = STDOUT
  Log = Logger.new target

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
