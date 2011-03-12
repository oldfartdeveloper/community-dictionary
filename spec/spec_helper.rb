require File.dirname(__FILE__) + '/../lib/init'

require "rspec"
require "faker"
require "timecop"

ENV['REDIS_URL'] ||= 'redis://127.0.0.1:6379/14'
ENV['RACK_ENV'] ||= 'test'

RSpec.configure do |config|
  config.before(:each) do
    Ohm.flush
    config.before { Timecop.return }
  end
end
