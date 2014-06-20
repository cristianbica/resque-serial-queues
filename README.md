# Resque::Plugins::SerialQueues

This gem is tested on the latest version from Resque 1.x.

Declaring resque queues as serial. Jobs from a serial queue won't be processed more than one at a time event if you have multiple workers / servers. There are similar solutions but none of them worked for me. To lock jobs from running in parallel I used `Redis#setnx`. This implementation has 2 sensitive things:
- `Resque::Job.reserve` is overriden (here the queue locking is done)
- Added `Object#after_perform_unlock_serial_queue` (here the queue is unlocked)

I think serial queues are not a scalable. You shouldn't have to have serial queues. This should be a temporary drop-in solution without changing the deployment process. If you really need serial job processing you should start a worker for each serial queue that will listen for jobs only on that queue or migrate to a background processing / messaging tool that provides serial processing out of the box.

## Installation

Add this line to your application's Gemfile:

    gem 'resque-serial-queues'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque-serial-queues

## Usage (Rails)

Create a `.rb` file in config/initializers

```ruby
Resque::Plugins::SerialQueues.configure do |config|
  config.serial_queues = [:serial_jobs]
  config.lock_timeout  = 120  #default 3600 seconds
end
```

and use the declared serial queues in your jobs:

```ruby
class MyJob

  @queue = :serial_jobs

  def perform(*)
  end

end
```

## Contributing

1. Fork it ( https://github.com/cristianbica/resque-serial-queues/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
