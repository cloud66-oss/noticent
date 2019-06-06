# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Channel do

  it 'should have protected properties' do
    Noticent.configure
    ch = Noticent::Channel.new(Noticent.configuration, [], {foo: :bar}, {})

    expect(ch).not_to be_nil
    expect(ch.send(:recipients)).not_to be_nil
    expect(ch.send(:payload)).not_to be_nil
    expect(ch.send(:configuration)).not_to be_nil
  end

  it 'should have current_user' do
    Noticent.configure
    r1 = build(:recipient)
    p1 = build(:post_payload, current_user: r1)

    ch = Noticent::Channel.new(Noticent.configuration, [], p1, {})

    expect(ch.send(:current_user)).not_to be_nil
    expect(ch.send(:current_user)).to equal(r1)
  end

  it 'should raise exception if no current user available' do
    Noticent.configure
    ch = Noticent::Channel.new(Noticent.configuration, [], { foo: :bar }, buzz: :fuzz)

    expect { ch.send(:current_user) }.to raise_error Noticent::NoCurrentUser
  end

  it 'should notify' do
    recs = create_list(:recipient, 3)
    p1 = build(:post_payload, _users: recs, some_attribute: 'hello')
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

  it 'should render' do
    recs = create_list(:recipient, 3)
    p1 = build(:post_payload, _users: recs, some_attribute: 'hello')
    Noticent.configure do
      channel(:email) {}
      scope :post do
        alert(:some_event) do
          notify(:users)
        end
      end
    end

    @payload = build(:post_payload, _users: recs, some_attribute: 'hello')
    ch = Noticent::Testing::Email.new(Noticent.configuration, [], @payload, {})
    data, content = ch.some_event

    expect(data).not_to be_nil
    expect(content).not_to be_nil
    expect(data[:foo]).to eq('bar')
    expect(content).to include('This is normal test')
    expect(data[:fuzz]).to eq('hello')
    expect(content).to include('This comes from hello')
    expect(content).to include('instance variable 1')
  end

end

