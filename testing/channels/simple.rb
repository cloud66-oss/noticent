module Noticent
  module Testing
    class Simple < ::Noticent::Channel
      def some_event
        render
      end
    end
  end
end
