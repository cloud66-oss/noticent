require 'spec_helper'

describe Noticent::Definitions::Channel do

  it 'can be configured' do
    ch = Noticent::Definitions::Channel.new(Noticent.configuration, :foo, group: :test)
    ch.configure(Integer).using(foo: :bar)

    expect(ch.klass).to eq(Integer)
    expect(ch.config_options).not_to be_nil
    expect(ch.config_options.options).to include(foo: :bar)
    expect(ch.name).to eq(:foo)
    expect(ch.group).to eq(:test)
  end

  it 'should have a default group' do
    ch = Noticent::Definitions::Channel.new(Noticent.configuration, :foo)
    expect(ch.group).to eq(:default)
  end

  it 'should support custom classes' do
    Noticent.configure {}
    ch = Noticent::Definitions::Channel.new(Noticent.configuration, :foo)
    expect(ch.klass).to eq(Noticent::Samples::Foo)
  end

  it 'should use custom initializers' do
    Noticent.configure do
      channel(:slack) do
        configure(Noticent::Samples::Slack)
          .using(foo: 1, bar: 2)
      end
      channel(:email) { configure(Noticent::Samples::Email).using(foo: :bar) }
    end

    ch = Noticent.configuration.channels[:slack]
    expect(ch.klass).to eq(Noticent::Samples::Slack)
    ch_obj = ch.instance
    expect(ch_obj).to be_a_kind_of(Noticent::Samples::Slack)

    ch = Noticent.configuration.channels[:email]
    expect { ch.instance }.to raise_error Noticent::BadConfiguration
  end

end
