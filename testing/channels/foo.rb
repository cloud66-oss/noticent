module Noticent
  module Testing
    class Foo < ::Noticent::Channel

      attr_accessor :buzz

      def boo
        render
      end
    end
  end
end