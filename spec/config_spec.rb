# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Config do

  it 'is configured' do
    expect(Noticent.opt_in_provider).not_to be_nil
  end

  it 'is a hash' do
    config = Noticent.configure {|config| nil}
    expect(config).to be_a_kind_of(Noticent::Config)
  end

  it 'returns config' do
    Noticent.configure {}

    expect(Noticent.configuration).to be_a_kind_of(Noticent::Config)
  end

  it 'should have hooks' do
    hooks = nil
    Noticent.configure do |config|
      hooks = config.hooks
    end

    expect(hooks).not_to be_nil
    expect(hooks).to be_a_kind_of(Noticent::Hooks)
  end

  it 'channel hooks should be addable' do
    Noticent.configure do |config|
      config.hooks.add(:pre_channel_registration, String)
      config.hooks.add(:post_channel_registration, Integer)
      config.hooks.add(:pre_channel_registration, Hash)
    end

    expect(Noticent.configuration.hooks).not_to be_nil
    expect(Noticent.configuration.hooks.send(:storage).count).to eq(2)
    expect(Noticent.configuration.hooks.send(:storage)[:pre_channel_registration].count).to eq(2)
    expect(Noticent.configuration.hooks.send(:storage)[:post_channel_registration].count).to eq(1)
    expect(Noticent.configuration.hooks.send(:storage)[:pre_channel_registration]).to include(String, Hash)
    expect(Noticent.configuration.hooks.send(:storage)[:post_channel_registration]).to include(Integer)
    expect(Noticent.configuration.hooks.fetch(:post_channel_registration)).to include(Integer)
    expect(Noticent.configuration.hooks.fetch(:pre_channel_registration)).to include(String, Hash)
    expect {Noticent.configuration.hooks.add(:bad_hook, String)}.to raise_error(Noticent::BadConfiguration)
  end

  it 'should have channel' do
    Noticent.configure do |config|
      config.channel(:email) do |channel|
        channel.configure(String)
      end
    end
  end

  it 'should find channels by group' do
    Noticent.configure do |config|
      config.channel(:email) {}
      config.channel(:slack) {}
      config.channel(:webhook, group: :special) {}
    end

    expect(Noticent.configuration.channels_by_group(:default).count).to eq(2)
    expect(Noticent.configuration.channels_by_group(:special).count).to eq(1)
    expect(Noticent.configuration.channels_by_group(:wrong)).not_to be_nil
    expect(Noticent.configuration.channels_by_group(:wrong)).to be_empty
  end

  it 'should not allow duplicate channels' do
    expect do
      Noticent.configure do |config|
        config.channel(:email) {}
        config.channel(:foo) {}
        config.channel(:email) {}
      end
    end.to raise_error(Noticent::BadConfiguration, 'channel \'email\' already defined')
  end

  it 'should have scopes and alerts' do
    expect do
      Noticent.configure do
        scope :s1 do
          alert(:tfa_enabled) {}
          alert(:sign_up, tags: %i[foo bar]) {}
        end
      end
    end.not_to raise_error

    expect(Noticent.configuration.scopes).not_to be_nil
    expect(Noticent.configuration.scopes.count).to eq(1)
    expect(Noticent.configuration.scopes[:s1]).not_to be_nil
    expect(Noticent.configuration.alerts).not_to be_nil
    expect(Noticent.configuration.scopes[:s2]).to be_nil
    expect(Noticent.configuration.alerts.count).to eq(2)
    expect(Noticent.configuration.alerts[:tfa_enabled].name).to eq(:tfa_enabled)
    expect(Noticent.configuration.alerts[:tfa_enabled].scope.name).to eq(:s1)
    expect(Noticent.configuration.alerts[:sign_up].tags).to eq(%i[foo bar])
  end

  it 'should force alert uniqueness across scopes' do
    expect do
      Noticent.configure do
        scope :s1 do
          alert(:a1) {}
        end
        scope :s2 do
          alert(:a1) {}
        end
      end
    end.to raise_error(Noticent::BadConfiguration)
  end

  it 'should handle bad notifications' do
    Noticent.configure do
      scope :s1 do
        alert(:boo) {}
      end

    end
    expect { Noticent.notify('hello', {}) }.to raise_error(Noticent::InvalidAlert)
    expect { Noticent.notify(:boo, {}) }.to raise_error(Noticent::BadConfiguration)
    payload = ::Noticent::Samples::S1Payload.new
    expect { Noticent.notify(:bar, payload) }.to raise_error(Noticent::InvalidAlert)
  end

  it 'should find the right alert' do
    Noticent.configure do

      scope :s1 do
        alert(:foo) {}
      end
    end

    expect { Noticent.notify(:foo, Noticent::Samples::S1Payload.new) }.not_to raise_error
    expect { Noticent.notify(:bar, Noticent::Samples::S1Payload.new) }.to raise_error(Noticent::InvalidAlert)
  end

  it 'should dispatch' do
    Noticent.configure do
      channel(:email) {}
      scope :s1 do
        alert(:new_signup) do
          notify(:users)
        end
      end
    end

    Noticent.notify(:new_signup, Noticent::Samples::S1Payload.new)
  end
end