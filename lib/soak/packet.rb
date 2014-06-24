module Soak
  class Packet

    def initialize dst_ip, src_ip, src_mac, head_data
      @dst_ip 		= dst_ip
      @src_ip 		= src_ip
      @src_mac 		= src_mac
      @head_data 	= head_data
      pkt_gen
      inject
    end

    def pkt_gen
      begin
        smac = Cfg.local_mac.split(':').pack 'H2H2H2H2H2H2'
        dmac = @src_mac.split(':').pack 'H2H2H2H2H2H2'
        opcode = [ 2 ].pack 'n'
        sha = Cfg.local_mac.split(':').pack 'H2H2H2H2H2H2'
        spa = @dst_ip.to_s.split('.').map{ |s| s.to_i }.pack 'CCCC'
        tha = @src_mac.split(':').pack 'H2H2H2H2H2H2'
        tpa = @src_ip.to_s.split('.').map{ |s| s.to_i }.pack 'CCCC'
        @packet = [ dmac, smac, @head_data, opcode, sha, spa, tha, tpa ].join
      rescue => e
        Log.warn e
      end
    end

    def inject
      begin
        RawSocket.send @packet, 0
        Log.debug "arp packet injected - sponge address: #{Cfg.local_mac}" if Cfg.debug
      rescue => e
	Log.warn e
      end
    end

  end
end
