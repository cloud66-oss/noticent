module Noticent
  class VersionChecker
    def self.activesupport_7_or_greater?
      return @activesupport_7_or_greater unless @activesupport_7_or_greater.nil?
      @activesupport_7_or_greater = ::Gem.loaded_specs["activesupport"].version >= ::Gem::Version.new("7.0.0")
    end
  end
end
