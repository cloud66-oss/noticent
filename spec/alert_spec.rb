# frozen_string_literal: true

require 'spec_helper'

describe ActAsNotified::Alert do

  it 'should validate fetch' do
    h = ActAsNotified::Hooks.new
    expect { h.fetch(:bad) }.to raise_error(::ArgumentError)
    expect { h.fetch(:pre_channel_registration) }.not_to raise_error
  end

  it 'should run the right method' do
    conf = ActAsNotified::Config.new
    alert = ActAsNotified::Alert.new(conf,
                                     name: :foo,
                                     scope: ActAsNotified::Scope.new(conf, :s1),
                                     tags: [:foo])
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
      config.scope :s1 do
        alert = alert(:foo) {}
      end
    end

    expect(custom_hook).to have_received(:pre_alert_registration).with(alert)
    expect(custom_hook).to have_received(:post_alert_registration).with(alert)
  end

  it 'adds notifiers' do
    ActAsNotified.configure do |config|
      scope :s1 do
        alert(:foo) do
          notify(:staff)
        end
      end
    end
  end

end