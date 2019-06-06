module Noticent
  module Testing
    # this is a example payload for comment as scope
    class CommentPayload < Noticent::Testing::Payload
      attr_accessor :comment_id
      attr_reader :users

      def self.three
        # nop
      end

      def self.new_signup
        # nop
      end

    end
  end
end