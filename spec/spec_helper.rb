require_relative '../lib/../lib/noticent'
Dir["#{File.dirname(__FILE__)}/../samples/**/*.rb"].each { |f| require f }
Noticent.base_dir = File.expand_path("#{File.dirname(__FILE__)}/../samples")
Noticent.base_module_name = 'Noticent::Samples'
Noticent.opt_in_provider = Noticent::Testing::InMemOptInProvider.new
Noticent.logger = Logger.new(STDOUT)
Noticent.halt_on_error = true