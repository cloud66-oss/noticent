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
    ch = Noticent::Channel.new([], ::Noticent::Samples::S1Payload.new, {})

    expect(ch.send(:current_user)).not_to be_nil
    expect(ch.send(:current_user)).to eq(:buzz)
  end

  it 'should raise exception if no current user available' do
    ch = Noticent::Channel.new([], { foo: :bar }, buzz: :fuzz)

    expect { ch.send(:current_user) }.to raise_error Noticent::NoCurrentUser
  end

  it 'should notify' do
    Noticent.configure do
      channel(:email) {}
      scope :s1 do
        alert(:some_event) do
          notify(:users)
        end
      end
    end

    Noticent.notify(:some_event, ::Noticent::Samples::S1Payload.new)
  end

end

