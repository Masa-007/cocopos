# frozen_string_literal: true

require 'simplecov'

SimpleCov.start 'rails' do
  enable_coverage :branch
  minimum_coverage 30
  track_files 'app/models/**/*.rb'

  add_filter '/config/'
  add_filter '/db/'
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
