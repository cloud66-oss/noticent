# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Definitions::Channel do
  it 'can be configured' do
    Noticent.configure {}
    ch = Noticent::Definitions::Channel.new(Noticent.configuration, :foo, group: :test, klass: Integer)

    expect(ch.klass).to eq(Integer)
    expect(ch.name).to eq(:foo)
    expect(ch.group).to eq(:test)
  end

  it 'should have a default group' do
    Noticent.configure {}
    ch = Noticent::Definitions::Channel.new(Noticent.configuration, :foo)
    expect(ch.group).to eq(:default)
  end

  it 'should support custom classes' do
    Noticent.configure {}
    ch = Noticent::Definitions::Channel.new(Noticent.configuration, :foo)
    expect(ch.klass).to eq(Noticent::Testing::Foo)
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

  it 'should support options for channels' do
    Noticent.configure
    ch = Noticent::Definitions::Channel.new(Noticent.configuration, :foo)
    ch.using(fuzz: 1)

    expect { ch.instance(Noticent.configuration, [], ::Noticent::Testing::PostPayload.new, nil) }.to raise_error Noticent::BadConfiguration

    ch.using(buzz: 2)
    expect { ch.instance(Noticent.configuration, [], ::Noticent::Testing::PostPayload.new, nil) }.not_to raise_error
    inst = ch.instance(Noticent.configuration, [], ::Noticent::Testing::PostPayload.new, nil)
    expect(inst).to be_a Noticent::Testing::Foo
    expect(inst.buzz).to eq(2)
  end

  it 'should be configurable with using' do
    Noticent.configure do
      channel(:foo) do
        using(buzz: 2)
      end
    end

    ch = Noticent.configuration.channels[:foo]
    inst = ch.instance(Noticent.configuration, [], ::Noticent::Testing::PostPayload.new, nil)
    expect(inst).to be_a Noticent::Testing::Foo
    expect(inst.buzz).to eq(2)
  end

  it 'should support sub namespaces' do
    Noticent.configure do |config|
      config.use_sub_modules = true
    end

    expect { Noticent::Definitions::Channel.new(Noticent.configuration, :email) }.to raise_error Noticent::BadConfiguration
  end

  it 'should disallow duplicate channel names' do
    expect do
      Noticent.configure do
        channel :email
        channel :email
      end
    end.to raise_error Noticent::BadConfiguration

    expect do
      Noticent.configure do
        channel :foo, group: :email
        channel :email
      end
    end.to raise_error Noticent::BadConfiguration
  end

end
