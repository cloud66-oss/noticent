require_relative '../lib/act_as_notified'
Dir["#{File.dirname(__FILE__)}/../samples/**/*.rb"].each { |f| require f }
ActAsNotified.base_dir = File.expand_path("#{File.dirname(__FILE__)}/../samples")
ActAsNotified.base_module_name = 'ActAsNotified::Samples'
ActAsNotified.opt_in_provider = ActAsNotified::Testing::InMemOptInProvider.new