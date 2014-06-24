module Soak
  class Lookup

    def initialize
      @rx_queue = Queue.new
      @in_sock = Socket.new Socket::PF_PACKET, Socket::SOCK_RAW, 0x03_00
      listen
    end

    def listen
      enqueue = Thread.new do
        while true do
	  r, w, e = IO.select([@in_sock], nil, nil)
          if r[0]
            data = @in_sock.recvfrom_nonblock(1500).first
	    @rx_queue << data
          end
        end
      end
      worker = Thread.new do
	while true do
          begin
            @data = @rx_queue.pop
            if @data[0..13].unpack('nnnnnnn')[6].to_s(16).to_i == 806 # process arp packets only
	      pkt_lu
            end
          rescue => e
	    Log.warn e if Cfg.debug
	  end
        end
      end
      worker.join
    end

    def pkt_lu
      @src_mac = []
      pkt = @data[14..-1].unpack('nnCCnnnnL>nnnL>')
      case pkt[4].to_s(16).to_i
        when 1
          @dst_ip = IPAddr.new(pkt[12], Socket::AF_INET)
          if Cfg.sponge.include? @dst_ip.to_s
            [ pkt[5], pkt[6], pkt[7] ].each do |p|
              if p.to_s(16).size < 4
                @src_mac << [ [ '00' ] + [ p.to_s(16) ] ].join
              else
                @src_mac << p.to_s(16)
              end
            end
            @src_ip = IPAddr.new(pkt[8], Socket::AF_INET)
            Log.debug "matching arp request - target address:#{@dst_ip.to_s} - sender info:#{@src_ip} @ #{@src_mac}" if Cfg.debug
	    @src_mac = @src_mac.join.scan(/../).join ':'
            pkt = Packet.new @dst_ip, @src_ip, @src_mac, @data[12..19]
          else
            Log.debug "ip not in sponge database - #{@dst_ip.to_s} .. ignoring .." if Cfg.debug
          end
      end
    end

  end
end
