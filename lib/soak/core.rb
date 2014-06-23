module Soak
  class Core

    def initialize
      @sock = Socket.new Socket::PF_PACKET, Socket::SOCK_RAW, 0x03_00
      @rx_queue = Queue.new
      listen
    end

    def listen
      enqueue = Thread.new do
        while true do
	  r, w, e = IO.select([@sock], nil, nil)
          if r[0]
            data = @sock.recvfrom_nonblock(1500).first
	    @rx_queue << data
          end
        end
      end
      worker = Thread.new do
	while true do
          begin
            data = @rx_queue.pop
            if data[0..13].unpack('nnnnnnn')[6].to_s(16).to_i == 806 # process arp packets only
	      pkt = Packet.new data
              pkt.sponge
            end
          rescue => e
	    Log.warn e if Cfg.debug
	  end
        end
      end
      worker.join
    end

  end
end
