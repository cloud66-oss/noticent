# frozen_string_literal: true

require_relative '../lib/noticent'
Dir["#{File.dirname(__FILE__)}/../samples/**/*.rb"].each { |f| require f }

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
load File.join(File.dirname(__FILE__), 'schema.rb')

Noticent.base_dir = File.expand_path("#{File.dirname(__FILE__)}/../samples")
Noticent.base_module_name = 'Noticent::Samples'
# Noticent.opt_in_provider = Noticent::Testing::InMemOptInProvider.new
Noticent.opt_in_provider = Noticent::ActiveRecordOptInProvider.new
Noticent.logger = Logger.new(STDOUT)
Noticent.halt_on_error = true
