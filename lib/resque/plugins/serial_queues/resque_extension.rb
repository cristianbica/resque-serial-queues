require 'resque'
require 'resque/job'

class Resque::Job
  def self.reserve(queue)
    return if is_serial_queue?(queue) and not lock_queue(queue)
    return unless payload = Resque.pop(queue)
    new(queue, payload)
  end

  protected
    def self.is_serial_queue?(queue)
      Resque::Plugins::SerialQueues.is_queue_serial?(queue)
    end

    def self.lock_queue(queue)
      Resque::Plugins::SerialQueues.lock_queue(queue)
    end
end

class Object
  def self.after_perform_unlock_queue(*)
    Resque::Plugins::SerialQueues.unlock_queue(@queue)
  end
end
