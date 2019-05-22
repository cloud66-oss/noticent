require 'spec_helper'

describe Noticent::Definitions::Channel do

  it 'can be configured' do
    ch = Noticent::Definitions::Channel.new(Noticent.configuration, :foo, group: :test)
    ch.configure(Integer)

    expect(ch.klass).to eq(Integer)
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

  it 'should expect channel to inherit from ::Noticent::Channel' do
    class BadChannel; end

    expect do
      Noticent.configure do
        channel(:bad_channel) { configure(BadChannel) }
      end
    end.to raise_error Noticent::BadConfiguration
  end

  it 'should use the right class for channel' do
    expect do
      Noticent.configure do
        channel(:some_channel) {}
      end
    end.to raise_error Noticent::BadConfiguration
  end

end
