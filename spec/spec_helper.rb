if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
end

require 'ghost_in_the_post'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
end

Dir['./spec/support/**/*.rb'].each { |file| require file }
