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
        end
      end
    end.not_to raise_error

    expect(ActAsNotified.configuration.scopes).not_to be_nil
    expect(ActAsNotified.configuration.scopes.count).to eq(1)
    expect(ActAsNotified.configuration.scopes[:s1]).not_to be_nil
    expect(ActAsNotified.configuration.scopes[:s1].alerts).not_to be_nil
    expect(ActAsNotified.configuration.scopes[:s2]).to be_nil
    expect(ActAsNotified.configuration.scopes[:s1].alerts.count).to eq(1)
    expect(ActAsNotified.configuration.scopes[:s1].alerts[:tfa_enabled].name).to eq(:tfa_enabled)
    expect(ActAsNotified.configuration.scopes[:s1].alerts[:tfa_enabled].scope.name).to eq(:s1)
  end

end