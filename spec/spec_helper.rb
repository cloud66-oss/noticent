# frozen_string_literal: true

# forced, not defaulted: a RAILS_ENV=development exported by the shell breaks the boot, as database.yml only defines test
ENV["RAILS_ENV"] = "test"

require "bundler"
Bundler.require :default, :development

#Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true
Combustion.initialize! :all

require_relative "../lib/noticent"
Dir["#{File.dirname(__FILE__)}/../testing/**/*.rb"].each { |f| require f }

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
load File.join(File.dirname(__FILE__), "schema.rb")

require "factory_bot"
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

ENV["NOTICENT_RSPEC"] = "1"
