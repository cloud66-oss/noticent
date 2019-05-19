require 'active_support/all'

Dir["#{File.dirname(__FILE__)}/act_as_notified/**/*.rb"].each { |f| load(f) }

module ActAsNotified
  class << self
    attr_accessor :base_dir
    attr_accessor :base_module_name
  end

  def self.payload_dir
    File.join(base_dir, 'payloads')
  end

  def self.scope_dir
    File.join(base_dir, 'scopes')
  end

  def self.channel_dir
    File.join(base_dir, 'channels')
  end

  def self.view_dir
    File.join(base_dir, 'views')
  end
end
