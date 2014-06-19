require 'minitest_helper'
require 'jobs/sleeping_job'
require 'jobs/delayed_failing_job'
require 'jobs/benchmark_job'

class LockingTest < ResqueSerialQueuesTest

  def test_checking_if_a_queue_is_serial
    assert_serial_queue :serial_jobs
  end

  def test_checking_if_a_queue_is_not_serial
    assert_concurrent_queue :parallel_jobs
  end

  def test_locking_a_queue
    assert Resque::Plugins::SerialQueues.lock_queue(:serial_jobs)
    assert_queue_locked :serial_jobs
  end

  def test_queue_lock_timeout
    timeout_was = Resque::Plugins::SerialQueues.config.lock_timeout
    Resque::Plugins::SerialQueues.config.lock_timeout = 1
    Resque::Plugins::SerialQueues.lock_queue(:serial_jobs)
    assert_queue_locked :serial_jobs
    sleep 1.1
    assert_queue_unlocked :serial_jobs
  ensure
    Resque::Plugins::SerialQueues.config.lock_timeout = timeout_was
  end

  def test_a_queue_is_locked_while_running
    self.class.start_redis_workers 1
    Resque.enqueue SleepingJob, 1
    sleep 0.5
    assert_queue_locked :serial_jobs
  end

  def test_a_queue_is_not_locked_after_running
    self.class.start_redis_workers 1
    Resque.enqueue SleepingJob, 0.1
    sleep 0.4
    assert_queue_unlocked :serial_jobs
  end

  def test_a_queue_is_not_locked_after_a_job_fails
    self.class.start_redis_workers 1
    Resque.enqueue DelayedFailingJob, 0.1
    sleep 0.4
    assert_queue_unlocked :serial_jobs
  end

  def test_running_many_concurrent_jobs
    jobs = 1000
    max_sleep = 0.05
    workers = 20
    self.class.start_redis_workers workers
    jobs.times do
      Resque.enqueue BenchmarkJob, max_sleep
    end
    assert_queue_locked :serial_jobs
    while Resque.info[:pending]>0
      sleep 0.1
      assert Resque.info[:working]<=1
    end
    assert_queue_unlocked :serial_jobs
    results = []
    while row = Resque::Plugins::SerialQueues.redis.lpop("benchmark-results")
      results << row.split("-").map(&:to_f)
    end
    results.flatten!
    assert_equal results, results.sort
  end

end
