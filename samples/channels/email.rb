module ActAsNotified
  module Samples
    class Email

      def new_signup(recipients, payload)
        # NOTE: This is only for testing
        { recipients: recipients, payload: payload }
      end

    end
  end
end