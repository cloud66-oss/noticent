require 'spec_helper'

describe ActAsNotified::Config do

  it 'is a hash' do
    config = ActAsNotified.configure { |config| nil }
    expect(config).to be_a_kind_of(ActAsNotified::Config)
  end

  it 'returns config' do
    ActAsNotified.configure {}

    expect(ActAsNotified.configuration).to be_a_kind_of(ActAsNotified::Config)
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

  it 'should have scopes and alerts' do
    expect do
      ActAsNotified.configure do
        scope :s1 do
          alert(:tfa_enabled) {}
          alert(:sign_up, tags: %i[foo bar]) {}
        end
      end
    end.not_to raise_error

    expect(ActAsNotified.configuration.scopes).not_to be_nil
    expect(ActAsNotified.configuration.scopes.count).to eq(1)
    expect(ActAsNotified.configuration.scopes[:s1]).not_to be_nil
    expect(ActAsNotified.configuration.alerts).not_to be_nil
    expect(ActAsNotified.configuration.scopes[:s2]).to be_nil
    expect(ActAsNotified.configuration.alerts.count).to eq(2)
    expect(ActAsNotified.configuration.alerts[:tfa_enabled].name).to eq(:tfa_enabled)
    expect(ActAsNotified.configuration.alerts[:tfa_enabled].scope.name).to eq(:s1)
    expect(ActAsNotified.configuration.alerts[:sign_up].tags).to eq(%i[foo bar])
  end

  it 'should force alert uniqueness across scopes' do
    expect do
      ActAsNotified.configure do
        scope :s1 do
          alert(:a1) {}
        end
        scope :s2 do
          alert(:a1) {}
        end
      end
    end.to raise_error(ActAsNotified::BadConfiguration)
  end

  it 'should handle bad notifications' do
    ActAsNotified.configure {}
    expect { ActAsNotified.notify('hello', {}) }.to raise_error(::ArgumentError)
    expect { ActAsNotified.notify(:foo, {}) }.to raise_error(ActAsNotified::BadConfiguration)
    payload = ::ActAsNotified::Samples::FooPayload.new
    expect { ActAsNotified.notify(:bar, payload) }.to raise_error(ActAsNotified::BadConfiguration)
  end

  it 'should find the right alert' do
    ActAsNotified.base_dir("#{File.dirname(__FILE__)}/../samples")
    ActAsNotified.configure do

      scope :s1 do
        alert(:foo) {}
      end
    end

    expect { ActAsNotified.notify(:foo, ActAsNotified::Samples::FooPayload.new) }.not_to raise_error
    expect { ActAsNotified.notify(:bar, ActAsNotified::Samples::FooPayload.new) }.to raise_error(ActAsNotified::InvalidScope)
  end
end