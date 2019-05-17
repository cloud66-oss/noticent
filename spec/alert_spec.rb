# frozen_string_literal: true

require 'spec_helper'

describe ActAsNotified::Alert do

  it 'should validate fetch' do
    h = ActAsNotified::Hooks.new
    expect { h.fetch(:bad) }.to raise_error(::ArgumentError)
    expect { h.fetch(:pre_channel_registration) }.not_to raise_error
  end

  it 'should run the right method' do
    alert = ActAsNotified::Alert.new(ActAsNotified::Config.new, :foo)
    custom_hook = double(:custom_hook)
    allow(custom_hook).to receive(:pre_alert_registration)
    allow(custom_hook).to receive(:post_alert_registration)
    h = ActAsNotified::Hooks.new
    h.add(:pre_alert_registration, custom_hook)
    h.run(:pre_alert_registration, alert)

    expect(custom_hook).to have_received(:pre_alert_registration).with(alert)
    expect(custom_hook).not_to have_received(:post_alert_registration).with(alert)
  end

  it 'runs the hooks in the right order' do
    alert = nil
    custom_hook = double(:custom_hook)
    allow(custom_hook).to receive(:pre_alert_registration)
    allow(custom_hook).to receive(:post_alert_registration)

    ActAsNotified.configure do |config|
      config.hooks.add(:pre_alert_registration, custom_hook)
      config.hooks.add(:post_alert_registration, custom_hook)
      alert = config.alert(:foo) {}
    end

    expect(custom_hook).to have_received(:pre_alert_registration).with(alert)
    expect(custom_hook).to have_received(:post_alert_registration).with(alert)
  end

  it 'should validate scope' do
    config = ActAsNotified::Config.new

    expect { ActAsNotified::Alert.new(config, :foo) }.not_to raise_error
    expect { ActAsNotified::Alert.new(config, :foo, scope: [:all]) }.not_to raise_error

    config = ActAsNotified.configure do |c|
      c.for_scopes do
        use(:s1, ->(p) {})
        use(:s2, ->(p) {})
      end
    end

    expect { ActAsNotified::Alert.new(config, :foo) }.to raise_error(ActAsNotified::BadConfiguration)
    expect { ActAsNotified::Alert.new(config, :foo, scope: [:s1]) }.not_to raise_error
    expect { ActAsNotified::Alert.new(config, :foo, scope: %i[s1 all]) }.to raise_error(ActAsNotified::BadConfiguration)
  end

end