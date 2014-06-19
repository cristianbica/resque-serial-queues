class BenchmarkJob
  @queue = :serial_jobs

  def self.perform(max_seconds)
    t0 = Time.now.to_f
    sleep rand*1000%max_seconds
    t1 = Time.now.to_f
    Resque::Plugins::SerialQueues.redis.rpush "benchmark-results", [t0, t1].join("-")
  end

end
