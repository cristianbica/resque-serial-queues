# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque-serial-queues/version'

Gem::Specification.new do |spec|
  spec.name          = "resque-serial-queues"
  spec.version       = Resque::Plugins::SerialQueues::VERSION
  spec.authors       = ["Cristian Bica"]
  spec.email         = ["cristian.bica@gmail.com"]
  spec.summary       = %q{Declare resque queues serial}
  spec.description   = %q{Declare resque queues serial and jobs in that queue will be run in serial mode}
  spec.homepage      = "http://github.com/cristianbica/resque-serial-queues"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'resque', '~>1.0'
  spec.add_dependency 'redis-namespace'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
