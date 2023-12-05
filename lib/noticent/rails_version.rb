module Noticent
  class RailsVersion
    def self.rails_7_or_greater?
      ::Gem.loaded_specs["rails"].version.to_s.to_i >= 7
    end
  end
end
