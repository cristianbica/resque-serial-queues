require 'resque'
require 'resque/job'

class Resque::Job
  def self.reserve(queue)
    return if queue=="*"
    return if is_serial_queue?(queue) and is_queue_locked?(queue)
    return if is_serial_queue?(queue) and Resque.peek(queue) and not lock_queue(queue)
    if payload = Resque.pop(queue)
      new(queue, payload)
    else
      unlock_queue(queue)
      nil
    end
  rescue Exception => e
    unlock_queue(queue)
    nil
  end

  protected
    def self.is_serial_queue?(queue)
      Resque::Plugins::SerialQueues.is_queue_serial?(queue)
    end

    def self.is_queue_locked?(queue)
      Resque::Plugins::SerialQueues.is_queue_locked?(queue)
    end

    def self.lock_queue(queue)
      Resque::Plugins::SerialQueues.lock_queue(queue)
    end

    def self.unlock_queue(queue)
      Resque::Plugins::SerialQueues.unlock_queue(queue)
    end
end

class Object
  def self.after_perform_unlock_queue_if_serial(*)
    Resque::Plugins::SerialQueues.unlock_queue(@queue) if Resque::Plugins::SerialQueues.is_queue_serial?(@queue)
  end

  def self.on_failure_unlock_queue_if_serial(*)
    Resque::Plugins::SerialQueues.unlock_queue(@queue) if Resque::Plugins::SerialQueues.is_queue_serial?(@queue)
  end
end
