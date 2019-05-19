# frozen_string_literal: true

require 'spec_helper'

describe ActAsNotified::NotificationEngine do

  it 'should find scope by alert' do
    ActAsNotified.configure do
      scope :s1 do
        alert(:foo) {}
      end
    end

    notification_engine = ActAsNotified::NotificationEngine.new(
      ActAsNotified.configuration,
      :foo,
      ActAsNotified::Samples::FooPayload.new
    )

    expect(notification_engine.alert).not_to be_nil
    expect(notification_engine.alert.name).to eq(:foo)
    expect(notification_engine.scope).not_to be_nil
    expect(notification_engine.scope.name).to eq(:s1)
  end

  it 'should find all recipients' do
    ActAsNotified.configure do
      scope :s1 do
        alert(:foo) do
          notify(:email)
        end
      end
    end

    notification_engine = ActAsNotified::NotificationEngine.new(
      ActAsNotified.configuration,
      :foo,
      ActAsNotified::Samples::FooPayload.new
    )

    expect(notification_engine.notifiers).not_to be_nil
    expect(notification_engine.notifiers.count).to eq(1)
    expect(notification_engine.notifiers[:email]).not_to be_nil
    expect(notification_engine.notifiers[:slack]).to be_nil
  end

  it 'should call scope to fetch recipients' do
    ActAsNotified.configure do
      scope :s1 do
        alert(:foo) do
          notify(:email)
        end
      end
    end

    notification_engine = ActAsNotified::NotificationEngine.new(
      ActAsNotified.configuration,
      :foo,
      ActAsNotified::Samples::FooPayload.new
    )

    expect(notification_engine.notifiers).not_to be_nil
    expect(notification_engine.notifiers.count).to eq(1)
    expect(notification_engine.notifiers[:email]).not_to be_nil
    expect(notification_engine.notifiers[:slack]).to be_nil
  end

  it 'should create the correct class name' do
    ActAsNotified.configure do
      scope :s1 do
        alert(:foo) do
          notify(:email)
        end
      end
    end

    notification_engine = ActAsNotified::NotificationEngine.new(
      ActAsNotified.configuration,
      :foo,
      ActAsNotified::Samples::FooPayload.new
    )

    expect(notification_engine.send(:user_scope)).to eq(ActAsNotified::Samples::S1)
  end

end

