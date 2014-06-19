module Resque
  module Plugins
    module SerialQueues
      class Config
        attr_accessor :serial_queues
        attr_accessor :lock_timeout

        def initialize
          self.serial_queues = []
          self.lock_timeout  = 60*60
        end

        def serial_queues=(queues)
          raise "queues should be an Array" unless queues.is_a?(Array)
          @serial_queues = queues.map(&:to_s)
        end
      end
    end
  end
end
