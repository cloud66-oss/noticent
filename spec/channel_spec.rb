require 'spec_helper'

describe ActAsNotified::Channel do

  it 'can be configured' do
    ch = ActAsNotified::Channel.new(:foo, group: :test)
    ch.configure(Integer).using(foo: :bar)

    expect(ch.configurer).to eq(Integer)
    expect(ch.config_options).not_to be_nil
    expect(ch.config_options.options).to include(foo: :bar)
    expect(ch.name).to eq(:foo)
    expect(ch.group).to eq(:test)
  end

  it 'should have a default group' do
    ch = ActAsNotified::Channel.new(:foo)
    expect(ch.group).to eq(:default)
  end

end
