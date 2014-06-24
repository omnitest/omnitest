require 'simplecov'
SimpleCov.start

require 'polytrix'
require 'polytrix/rspec'
require 'fabrication'
require 'thor_spy'

Polytrix.configure do |polytrix|
  Dir['sdks/*'].each do |sdk|
    polytrix.build_implementor sdk
  end
end

RSpec.configure do |c|
  c.before(:each) do
    Polytrix::ValidatorRegistry.clear
  end
end
