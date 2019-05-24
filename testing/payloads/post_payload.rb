require_relative 'payload'

module Noticent
  module Testing
    # this is an example payload for post as scope
    class PostPayload < Noticent::Testing::Payload
      attr_accessor :_post
      attr_accessor :some_attribute

      def post
        @_post
      end

      def users
        @_post.users
      end

    end
  end
end