$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'resque-serial-queues'
require "minitest"
require 'minitest/test'
Minitest.autorun

Resque::Plugins::SerialQueues.configure do |config|
  config.serial_queues = [:serial_jobs]
  config.lock_timeout  = 60
end

Resque.redis = "127.0.0.1:6379:10/resque-serial-queues:resque"

$redis_workers_pids = []

trap("INT")  { ResqueSerialQueuesTest.stop_redis_workers(true); exit! }
trap("TERM") { ResqueSerialQueuesTest.stop_redis_workers(true); exit! }
trap("QUIT") { ResqueSerialQueuesTest.stop_redis_workers(true); exit! }

class ResqueSerialQueuesTest < Minitest::Test

  #alias_method :run_without_resque_serial_queue_hooks, :run
  def run(*args)
    log "Running test #{self.name}"
    self.class.clear_redis_keys
    r = super
    self.class.stop_redis_workers
    self.class.clear_redis_keys
    log "Finished running test #{self.name}"
    r
  end

  def assert_queue_locked(queue)
    assert Resque::Plugins::SerialQueues.is_queue_locked?(queue), "Queue #{queue} should be locked but it's unlocked"
  end

  def assert_queue_unlocked(queue)
    assert !Resque::Plugins::SerialQueues.is_queue_locked?(queue), "Queue #{queue} should be unlocked but it's locked"
  end

  def assert_serial_queue(queue)
    assert Resque::Plugins::SerialQueues.is_queue_serial?(queue), "Queue #{queue} should be serial but it's concurrent"
  end

  def assert_concurrent_queue(queue)
    assert !Resque::Plugins::SerialQueues.is_queue_serial?(queue), "Queue #{queue} should be concurrent but it's serial"
  end

  def log(message)
    self.class.log(message)
  end

  def self.log(message)
    puts "[PID: #{Process.pid}] [#{Time.now.to_f}] #{message}"
  end

  protected
    def self.start_redis_workers(number_of_workers = 1)
      number_of_workers.times do
        start_worker
      end
    end

    def self.start_worker
      if pid = Kernel.fork
        log "Forked to pid #{pid} to start worker"
        started = wait_for_worker_to_start(pid)
        log "Waiting for worker to start"
        if started
          log "Worker started"
          $redis_workers_pids << pid
        else
          raise "Failed to start worker"
        end
      else
        begin
          Resque.redis.client.reconnect
          # we need to prevent against querying for jobs in "*"
          Resque.watch_queue :test_queue
          # Resque.logger = MonoLogger.new(File.open(File.expand_path('../../log', __FILE__) << "/resque-#{Process.pid}.log", "w+"))
          # Resque.logger.level = Logger::DEBUG
          # Resque.logger.formatter = Resque::VerboseFormatter.new
          worker = Resque::Worker.new("*")
          worker.term_timeout = 4.0
          worker.term_child = true
          log "Worker will start working"
          worker.work 0.1
          Kernel.exit!
        rescue Exception => e
          log "Failed to start worker: #{e.inspect}"
          Kernel.exit!
        end
      end
    end

    def self.wait_for_worker_to_start(pid)
      worker_started = false
      25.times do
        worker_started = worker_exists?(pid)
        break if worker_started
        sleep 0.2
      end
      worker_started
    end

    def self.wait_for_worker_to_finish(pid)
      worker_finished = false
      25.times do
        worker_finished = !worker_exists?(pid)
        break if worker_finished
        sleep 0.2
      end
      worker_finished
    end

    def self.worker_exists?(pid)
      Resque::Worker.all.map(&:to_s).grep(/\:#{pid}\:/).any?
    end

    def self.stop_redis_workers(forced=false)
      while pid = $redis_workers_pids.pop do
        log "Stopping worker with pid #{pid} (QUIT)"
        Process.kill "QUIT", pid
        log "Stopping worker with pid #{pid} (TERM)" and Process.kill "TERM", pid if forced or not wait_for_worker_to_finish(pid)
        log "Stopped worker with pid #{pid}"
        Process.kill 9, pid rescue nil
      end
    end

    def self.clear_redis_keys
      log "Clear redis keys"
      Resque.redis.keys("*").each do |key|
        Resque.redis.del(key)
      end
    end

end
