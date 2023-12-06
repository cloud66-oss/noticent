module Noticent
  class VersionChecker
    def self.activesupport_7_or_greater?
      return @activesupport_7_or_greater unless @activesupport_7_or_greater.nil?
      @activesupport_7_or_greater = ::Gem.loaded_specs["activesupport"].version.to_s.to_i >= 7
    end
  end
end
