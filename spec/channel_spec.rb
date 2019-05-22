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
    ch = Noticent::Channel.new([], { foo: :bar }, current_user: :bar)

    expect(ch.send(:context)[:current_user]).not_to be_nil
    expect(ch.send(:context)[:current_user]).to eq(:bar)
    expect(ch.send(:current_user)).to eq(:bar)
  end

  it 'should raise exception if no current user available' do
    ch = Noticent::Channel.new([], { foo: :bar }, buzz: :fuzz)

    expect { ch.send(:current_user) }.to raise_error Noticent::NoCurrentUser
  end

end

