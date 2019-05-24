# frozen_string_literal: true

require 'active_support/all'

Dir["#{File.dirname(__FILE__)}/noticent/**/*.rb"].each { |f| load(f) }

module Noticent
end
