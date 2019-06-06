module Noticent
  module Testing
    class Email < ::Noticent::Channel

      def new_signup
        # NOTE: This is only for testing
        { recipients: recipients, payload: payload }
      end

      def some_event
        @some_value = 1
        render
      end

      def foo
        render
      end

    end
  end
end