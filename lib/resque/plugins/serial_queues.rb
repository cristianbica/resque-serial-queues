module Resque
  module Plugins
    module SerialQueues extend self
      def config
        @config ||= Config.new
      end

      def configure
        yield(config) if block_given?
      end

      def redis
        @redis ||= Redis::Namespace.new(:serial_queues, redis: Resque.redis)
      end

      def self.is_queue_serial?(queue)
        config.serial_queues.include?(queue.to_s)
      end

      def self.lock_queue(queue)
        if redis.setnx("queue-lock:#{queue}", 1)
          redis.expire("queue-lock:#{queue}", config.lock_timeout)
          true
        else
          false
        end
      end

      def self.is_queue_locked?(queue)
        redis.exists("queue-lock:#{queue}")
      end

      def self.unlock_queue(queue)
        redis.del("queue-lock:#{queue}")
      end
    end
  end
end
