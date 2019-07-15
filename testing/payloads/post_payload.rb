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

      def owners
        []
      end

      def self.some_event(some_value)
        # nop
      end

      def self.foo(options)
        # nop
      end

      def self.boo
        # nop
      end

      def self.one
        # nop
	  end
	  
	  def self.only_here
		# nop
	  end

      def self.two
        # nop
      end

      def self.tfa_enabled
        # nop
      end

      def self.sign_up
        # nop
      end

      def self.new_signup
        # nop
      end

      def self.fuzz
        # nop
      end

      def self.buzz
        # nop
      end

    end
  end
end