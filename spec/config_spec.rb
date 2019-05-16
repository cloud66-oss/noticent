require 'spec_helper'

describe ActAsNotified::Config do

  it 'is a hash' do
    config = ActAsNotified.configure { |config| nil }
    expect(config).to be_a_kind_of(ActAsNotified::Config)
  end

  it 'returns config' do
    ActAsNotified.configure do |config|
      config.for_payloads do
        use(:foo, ->(payload) { return :foo })
        use(:bar, ->(payload) { return :bar })
      end
    end

    expect(ActAsNotified.configuration).to be_a_kind_of(ActAsNotified::Config)
    expect(ActAsNotified.configuration.payloads).not_to be_nil
    expect(ActAsNotified.configuration.payloads.count).to eq(2)
  end

  it 'has payload_as' do
    ActAsNotified.configure do |config|
      config.for_payloads do
        # do something
      end
    end
  end

  it 'build payload map' do
    payloads = nil
    ActAsNotified.configure do |config|
      payloads = config.for_payloads do
        use(:test, ->(payload) { return payload })
      end
    end

    expect(payloads).not_to be_nil
    expect(payloads.fetch(:test)).to be_a_kind_of Proc
    result = payloads.fetch(:test).call('built payload map')
    expect(result).to eq('built payload map')
  end

  it 'build scopers map' do
    scopers = nil
    ActAsNotified.configure do |config|
      scopers = config.for_scopes do
        use(:test, ->(payload) { return payload })
      end
    end

    expect(scopers).not_to be_nil
    expect(scopers.fetch(:test)).to be_a_kind_of Proc
    result = scopers.fetch(:test).call('built scopers map')
    expect(result).to eq('built scopers map')
  end

  it 'build recipients map' do
    recipients = nil
    another = nil
    ActAsNotified.configure do |config|
      recipients = config.recipients(:owner) do
        use(:test, ->(payload) { return payload })
      end
      another = config.recipients(:buyer) do
        use(:test, ->(payload) { return payload })
      end
    end

    expect(recipients).not_to be_nil
    expect(recipients.fetch(:test)).to be_a_kind_of Proc
    result = recipients.fetch(:test).call('built recipients map')
    expect(result).to eq('built recipients map')
    expect(ActAsNotified.configuration.recipients[:owner]).to equal(recipients)
    expect(ActAsNotified.configuration.recipients[:buyer]).to equal(another)
  end

  it 'setup scope alias' do
    ActAsNotified.configure do |config|
      config.scope_alias(foo: :bar, fuzz: :buzz)
    end

    expect(ActAsNotified.configuration.aliases).to be_a_kind_of Hash
    expect(ActAsNotified.configuration.aliases[:foo]).to eq(:bar)
  end

  it 'should have hooks' do
    hooks = nil
    ActAsNotified.configure do |config|
      hooks = config.hooks
    end

    expect(hooks).not_to be_nil
    expect(hooks).to be_a_kind_of(ActAsNotified::Hooks)
  end

  it 'hooks should be addable' do
    ActAsNotified.configure do |config|
      config.hooks.add(:pre_channel_registration, String)
      config.hooks.add(:post_channel_registration, Integer)
      config.hooks.add(:pre_channel_registration, Hash)
    end

    expect(ActAsNotified.configuration.hooks).not_to be_nil
    expect(ActAsNotified.configuration.hooks.send(:storage).count).to eq(2)
    expect(ActAsNotified.configuration.hooks.send(:storage)[:pre_channel_registration].count).to eq(2)
    expect(ActAsNotified.configuration.hooks.send(:storage)[:post_channel_registration].count).to eq(1)
    expect(ActAsNotified.configuration.hooks.send(:storage)[:pre_channel_registration]).to include(String, Hash)
    expect(ActAsNotified.configuration.hooks.send(:storage)[:post_channel_registration]).to include(Integer)
    expect(ActAsNotified.configuration.hooks.fetch(:post_channel_registration)).to include(Integer)
    expect(ActAsNotified.configuration.hooks.fetch(:pre_channel_registration)).to include(String, Hash)
    expect { ActAsNotified.configuration.hooks.add(:bad_hook, String) }.to raise_error(ActAsNotified::BadConfiguration)
  end

end