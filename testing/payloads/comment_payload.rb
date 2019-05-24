module Noticent
  module Testing
    # this is a example payload for comment as scope
    class CommentPayload < Noticent::Testing::Payload
      attr_accessor :comment_id
    end
  end
end