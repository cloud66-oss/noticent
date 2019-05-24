# frozen_string_literal: true

require 'active_record'

module Noticent
  class OptIn < ActiveRecord::Base
    # scope: is the type of domain object that opt-in applies to. For example
    # it could be post or comment
    # entity_id: is the ID of the scope (post id or comment id)
    # channel_name: is the name of the channel opted into. email or slack are examples
    # alert_name: is the name of the alert: new_user or comment_posted
    # user_id: is the name of the user who's opted into this

    self.table_name = :opt_ins

    validates_presence_of :scope, :entity_id, :channel_name, :alert_name, :recipient_id
    validates_uniqueness_of %i[scope entity_id channel_name alert_name], scope: :recipient_id
  end
end
