module Noticent
  module Samples
    class Email < ::Noticent::Channel

      def new_signup
        # NOTE: This is only for testing
        { recipients: recipients, payload: payload }
      end

    end
  end
end