# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Definitions::Hooks do

  it 'should validate fetch' do
    h = Noticent::Definitions::Hooks.new
    expect { h.fetch(:bad) }.to raise_error(::ArgumentError)
    expect { h.fetch(:pre_channel_registration) }.not_to raise_error
  end

  it 'should run the right method' do
    chan = Noticent::Definitions::Channel.new(Noticent::Config.new, :email)
    custom_hook = double(:custom_hook)
    allow(custom_hook).to receive(:pre_channel_registration)
    allow(custom_hook).to receive(:post_channel_registration)
    h = Noticent::Definitions::Hooks.new
    h.add(:pre_channel_registration, custom_hook)
    h.run(:pre_channel_registration, chan)

    expect(custom_hook).to have_received(:pre_channel_registration).with(chan)
    expect(custom_hook).not_to have_received(:post_channel_registration).with(chan)
  end

  it 'runs the hooks in the right order' do
    chan = nil
    custom_hook = double(:custom_hook)
    allow(custom_hook).to receive(:pre_channel_registration)
    allow(custom_hook).to receive(:post_channel_registration)

    Noticent.configure do |config|
      config.hooks.add(:pre_channel_registration, custom_hook)
      config.hooks.add(:post_channel_registration, custom_hook)
      chan = config.channel(:email) do |channel|
        channel.configure(::Noticent::Samples::Email)
      end
    end

    expect(custom_hook).to have_received(:pre_channel_registration).with(chan)
    expect(custom_hook).to have_received(:post_channel_registration).with(chan)
  end

end