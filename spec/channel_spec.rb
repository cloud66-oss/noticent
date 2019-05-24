# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Channel do

  it 'should have protected properties' do
    ch = Noticent::Channel.new([], {foo: :bar}, {})

    expect(ch).not_to be_nil
    expect(ch.send(:recipients)).not_to be_nil
    expect(ch.send(:payload)).not_to be_nil
    expect(ch.send(:context)).not_to be_nil
  end

  it 'should have current_user' do
    r1 = build(:recipient)
    p1 = build(:post_payload, current_user: r1)

    ch = Noticent::Channel.new([], p1, {})

    expect(ch.send(:current_user)).not_to be_nil
    expect(ch.send(:current_user)).to equal(r1)
  end

  it 'should raise exception if no current user available' do
    ch = Noticent::Channel.new([], { foo: :bar }, buzz: :fuzz)

    expect { ch.send(:current_user) }.to raise_error Noticent::NoCurrentUser
  end

  it 'should notify' do
    recs = create_list(:recipient, 3)
    s1 = build(:post, users: recs)
    p1 = build(:post_payload, _post: s1, some_attribute: 'hello')
    Noticent.configure do
      channel(:email) {}
      scope :post do
        alert(:some_event) do
          notify(:users)
        end
      end
    end

    Noticent.notify(:some_event, p1)
  end

end

