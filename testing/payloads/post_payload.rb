require_relative 'payload'

module Noticent
  module Testing
    # this is an example payload for post as scope
    class PostPayload < Noticent::Testing::Payload
      attr_accessor :some_attribute
      attr_accessor :_users
      attr_accessor :post_id

      def users
        @_users
      end

    end
  end
end