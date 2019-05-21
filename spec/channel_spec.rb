require 'spec_helper'

describe ActAsNotified::Channel do

  it 'can be configured' do
    ch = ActAsNotified::Channel.new(ActAsNotified.configuration, :foo, group: :test)
    ch.configure(Integer).using(foo: :bar)

    expect(ch.klass).to eq(Integer)
    expect(ch.config_options).not_to be_nil
    expect(ch.config_options.options).to include(foo: :bar)
    expect(ch.name).to eq(:foo)
    expect(ch.group).to eq(:test)
  end

  it 'should have a default group' do
    ch = ActAsNotified::Channel.new(ActAsNotified.configuration, :foo)
    expect(ch.group).to eq(:default)
  end

  it 'should support custom classes' do
    ActAsNotified.configure {}
    ch = ActAsNotified::Channel.new(ActAsNotified.configuration, :foo)
    expect(ch.klass).to eq(ActAsNotified::Samples::Foo)
  end

  it 'should use custom initializers' do
    ActAsNotified.configure do
      channel(:slack) do
        configure(ActAsNotified::Samples::Slack)
          .using(foo: 1, bar: 2)
      end
      channel(:email) { configure(ActAsNotified::Samples::Email).using(foo: :bar) }
    end

    ch = ActAsNotified.configuration.channels[:slack]
    expect(ch.klass).to eq(ActAsNotified::Samples::Slack)
    ch_obj = ch.instance
    expect(ch_obj).to be_a_kind_of(ActAsNotified::Samples::Slack)

    ch = ActAsNotified.configuration.channels[:email]
    expect { ch.instance }.to raise_error ActAsNotified::BadConfiguration
  end

end
