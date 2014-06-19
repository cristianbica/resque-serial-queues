class DelayedFailingJob
  @queue = :serial_jobs

  def self.perform(seconds)
    sleep seconds
    raise
  end
end
