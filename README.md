# Resque::Plugins::SerialQueues

Declaring resque queues as serial.

## Installation

Add this line to your application's Gemfile:

    gem 'resque-serial-queues'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resque-serial-queues

## Usage

```ruby

Resque::Plugins::SerialQueues.configure do |config|
  config.serial_queues = [:serial_jobs]
  config.lock_timeout  = 120  #default 3600 seconds
end

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
