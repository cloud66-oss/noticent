module Noticent
  module Testing
    class Exclusive < ::Noticent::Channel
      def only_here
        render
      end
    end
  end
end
