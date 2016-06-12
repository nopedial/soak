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

    private

    def build_src_mac pkt
      src_mac = []
      [ pkt[5], pkt[6], pkt[7] ].each do |p|
        if p.to_s(16).size < 4
          src_mac << [ [ '00' ] + [ p.to_s(16) ] ].join
        else
          src_mac << p.to_s(16)
        end
      end
      return src_mac
    end

    def map_mac lock=false, dst_ip=nil
      ip = []
      Cfg.sponge.each do |p|
        if not lock
          ip << p.split('+')[0]
        else
          if p.split('+')[0] == dst_ip
            @v = p.split('+')[1]
          end
        end
      end
      @v = ip if not lock
      return @v
    end

    def pkt_lu
      @src_mac = []
      pkt = @data[14..-1].unpack('nnCCnnnnL>nnnL>')
      case pkt[4].to_s(16).to_i
        when 1
          @dst_ip = IPAddr.new(pkt[12], Socket::AF_INET)
          ip = map_mac
          if ip.include? @dst_ip.to_s
            @mapped_mac = map_mac true, @dst_ip.to_s
            @src_mac = build_src_mac(pkt)
            @src_ip = IPAddr.new(pkt[8], Socket::AF_INET)
            Log.debug [ 'matching arp request - target address:', @dst_ip.to_s, '- sender info:', @src_ip, '@', @src_mac ].join(' ') if Cfg.debug
	    @src_mac = @src_mac.join.scan(/../).join ':'
            pkt = Packet.new @dst_ip, @src_ip, @src_mac, @mapped_mac, @data[12..19]
          else
            Log.debug [ 'address is not in the database -', @dst_ip.to_s, '.. ignoring ..' ].join(' ') if Cfg.debug
          end
      end
    end

  end
end
