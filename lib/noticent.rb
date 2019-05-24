# frozen_string_literal: true

require 'active_support/all'

Dir["#{File.dirname(__FILE__)}/noticent/**/*.rb"].each { |f| load(f) }

module Noticent
  class << self
    attr_accessor :base_dir
    attr_accessor :base_module_name
    attr_accessor :opt_in_provider
    attr_accessor :logger
    attr_accessor :halt_on_error
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
