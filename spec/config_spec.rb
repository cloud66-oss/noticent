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

  it 'maps have config' do
    ActAsNotified.configure do |config|
      config.for_payloads { use(:foo, ->(payload) { return :foo }) }
    end

    expect(ActAsNotified.configuration.payloads).not_to be_nil
    expect(ActAsNotified.configuration.payloads.send(:config)).not_to be_nil
    expect(ActAsNotified.configuration.payloads.send(:config)).to equal(ActAsNotified.configuration)
  end

  it 'has payload duplicate protection' do
    expect do
      ActAsNotified.configure do |config|
        config.for_payloads {}
        config.for_payloads {}
      end
    end.to raise_error(ActAsNotified::BadConfiguration)
  end

  it 'has scope duplicate protection' do
    expect do
      ActAsNotified.configure do |config|
        config.for_scopes {}
        config.for_scopes {}
      end
    end.to raise_error(ActAsNotified::BadConfiguration)
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

  it 'build scopes map' do
    scopes = nil
    ActAsNotified.configure do |config|
      scopes = config.for_scopes do
        use(:test, ->(payload) { return payload })
      end
    end

    expect(scopes).not_to be_nil
    expect(scopes.fetch(:test)).to be_a_kind_of Proc
    result = scopes.fetch(:test).call('built scopes map')
    expect(result).to eq('built scopes map')
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

  it 'channel hooks should be addable' do
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

  it 'should have channel' do
    ActAsNotified.configure do |config|
      config.channel(:email) do |channel|
        channel.configure(String)
      end
    end
  end

  it 'should not allow duplicate channels' do
    expect do
      ActAsNotified.configure do |config|
        config.channel(:email) {}
        config.channel(:foo) {}
        config.channel(:email) {}
      end
    end.to raise_error(ActAsNotified::BadConfiguration, 'channel \'email\' already defined')
  end


  it 'should have alerts' do
    expect do
      ActAsNotified.configure do |config|
        config.alert(:tfa_enabled) {}
      end
    end.not_to raise_error

    expect(ActAsNotified.configuration.alerts).not_to be_nil
    expect(ActAsNotified.configuration.alerts.count).to eq(1)
    expect(ActAsNotified.configuration.alerts[:tfa_enabled]).not_to be_nil
  end

end