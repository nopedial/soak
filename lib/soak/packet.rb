module Soak
  class Packet

    ETH_P_ALL      =  0x03_00
    SIOCGIFINDEX   =  0x89_33
    PF_PACKET      =  17
    AF_PACKET      =  PF_PACKET

    def initialize pkt
      @pkt 		= pkt
      @src_mac 		= []
      @inj_socket 	= Socket.open Socket::PF_PACKET, Socket::SOCK_RAW, ETH_P_ALL
    end

    def sponge
      lookup
      if @lu_res and not Cfg.maint
        @src_mac = @src_mac.join.scan(/../).join ':'
	inject
      end
    end

    private

    def lookup
      pkt = @pkt[14..-1].unpack('nnCCnnnnL>nnnL>')
      case pkt[4].to_s(16).to_i
        when 1 # process arp requests only
          @dst_ip = IPAddr.new(pkt[12], Socket::AF_INET)
          if Cfg.sponge.include? @dst_ip.to_s
            [ pkt[5], pkt[6], pkt[7] ].each do |p|
              if p.to_s(16).size < 4
                @src_mac << [ [ '00'] + [ p.to_s(16) ] ].join # ugly padding for MACs that start with 00 .. fix me
              else
                @src_mac << p.to_s(16)
              end
            end
            @src_ip = IPAddr.new(pkt[8], Socket::AF_INET)
            Log.debug "matching arp request - target address:#{@dst_ip.to_s} - sender info:#{@src_ip} @ #{@src_mac.join('-')}" if Cfg.debug
            @lu_res = true
	  else
            Log.debug "ip not in sponge database - #{@dst_ip.to_s} .. ignoring .." if Cfg.debug
	    @lu_res = false
          end
      end
    end

    def inject
      begin
	smac = Cfg.local_mac.split(':').pack 'H2H2H2H2H2H2'
	dmac = @src_mac.split(':').pack 'H2H2H2H2H2H2'
	opcode = [ 2 ].pack 'n'
	sha = Cfg.local_mac.split(':').pack 'H2H2H2H2H2H2'
	spa = @dst_ip.to_s.split('.').map{ |s| s.to_i }.pack 'CCCC'
	tha = @src_mac.split(':').pack 'H2H2H2H2H2H2'
	tpa = @src_ip.to_s.split('.').map{ |s| s.to_i }.pack 'CCCC'
	packet = [ dmac, smac, @pkt[12..19], opcode, sha, spa, tha, tpa ].join
	ifreq = [ Cfg.interface.dup ].pack 'a32'
	@inj_socket.ioctl(SIOCGIFINDEX, ifreq)
	@inj_socket.bind [AF_PACKET].pack('s') + [ETH_P_ALL].pack('n') + ifreq[16..20]+ ("\x00" * 12)
	@inj_socket.send packet, 0
        Log.debug "arp packet injected - sponge address: #{Cfg.local_mac}" if Cfg.debug
      rescue => e
	Log.warn e
      end
    end

  end
end
