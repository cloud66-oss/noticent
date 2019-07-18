# frozen_string_literal: true

require "active_support/all"
require "rails/all"

Dir["#{File.dirname(__FILE__)}/noticent/**/*.rb"].each { |f| load(f) }
load "#{File.dirname(__FILE__)}/generators/noticent/noticent.rb"

module Noticent
end
