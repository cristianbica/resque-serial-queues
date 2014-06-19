class SleepingJob
  @queue = :serial_jobs

  def self.perform(seconds)
    sleep seconds
  end
end
