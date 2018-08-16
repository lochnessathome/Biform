require "bundler/setup"
Bundler.setup

require_relative "support/database_helper"
DatabaseHelper.connect
DatabaseHelper.migrate

require "biform"

RSpec.configure do |config|
end
