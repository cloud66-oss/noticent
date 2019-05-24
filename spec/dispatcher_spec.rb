# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Dispatcher do
  it 'should find scope by alert' do
    p1 = build(:post_payload)
    Noticent.configure do
      scope :post do
        alert(:foo) {}
      end
    end

    dispatcher = Noticent::Dispatcher.new(
      Noticent.configuration,
      :foo,
      p1
    )

    expect(dispatcher.alert).not_to be_nil
    expect(dispatcher.alert.name).to eq(:foo)
    expect(dispatcher.scope).not_to be_nil
    expect(dispatcher.scope.name).to eq(:post)
  end

  it 'should find all recipients' do
    p1 = build(:post_payload)
    Noticent.configure do
      scope :post do
        alert(:foo) do
          notify(:users)
        end
      end
    end

    dispatcher = Noticent::Dispatcher.new(
      Noticent.configuration,
      :foo,
      p1
    )

    expect(dispatcher.notifiers).not_to be_nil
    expect(dispatcher.notifiers.count).to eq(1)
    expect(dispatcher.notifiers[:users]).not_to be_nil
    expect(dispatcher.notifiers[:slack]).to be_nil
  end

  it 'should call scope to fetch recipients' do
    p1 = build(:post_payload)
    Noticent.configure do
      scope :post do
        alert(:foo) do
          notify(:users)
        end
      end
    end

    dispatcher = Noticent::Dispatcher.new(
      Noticent.configuration,
      :foo,
      p1
    )

    expect(dispatcher.notifiers).not_to be_nil
    expect(dispatcher.notifiers.count).to eq(1)
    expect(dispatcher.notifiers[:users]).not_to be_nil
    expect(dispatcher.notifiers[:slack]).to be_nil
  end

  it 'should fetch all recipients' do
    p1 = build(:post_payload, _users: create_list(:recipient, 4))
    Noticent.configure do
      scope :post do
        alert :foo do
          notify :users
        end
      end
    end

    dispatcher = Noticent::Dispatcher.new(
      Noticent.configuration,
      :foo,
      p1
    )

    expect(dispatcher.recipients(:users)).not_to be_nil
    expect(dispatcher.recipients(:users).count).to eq(4)
  end

  it 'should filter recipients' do
    rec = create_list(:recipient, 2)
    p1 = build(:post_payload, _users: rec)
    r1 = rec[0]

    Noticent.configure do
      channel(:email) {}
      scope :post do
        alert :foo do
          notify(:users).on(:default)
        end
      end
    end

    dispatcher = Noticent::Dispatcher.new(Noticent.configuration, :foo, p1)

    # clean up db
    Noticent::OptIn.delete_all

    # no opt ins yet
    expect(dispatcher.filter_recipients(rec, :email).count).to eq(0)

    # opt in one user
    Noticent.configuration.opt_in_provider.opt_in(recipient_id: r1.id, scope: :post, entity_id: p1.post_id, alert_name: :foo, channel_name: :email)

    # confirm the opt in
    expect(Noticent.configuration.opt_in_provider.opted_in?(recipient_id: r1.id, scope: :post, entity_id: p1.post_id, alert_name: :foo, channel_name: :email)).to be_truthy

    # we should have 1 user in now
    expect(dispatcher.filter_recipients(rec, :email).count).to eq(1)
    expect(dispatcher.filter_recipients(rec, :email)[0]).to equal(r1)
  end

  it 'should dispatch' do
    class Email < ::Noticent::Channel
      def new_signup
        raise Noticent::Error, 'bad recipients' unless recipients.count == 1
        raise Noticent::Error, 'bad payload' unless payload.is_a? Noticent::Testing::PostPayload
      end
    end

    rec = create_list(:recipient, 4)
    payload = build(:post_payload, _users: rec)
    r1 = rec[0]

    Noticent.configure do
      channel(:email, klass: Email) {}
      scope :post do
        alert :new_signup do
          notify(:users).on(:default)
        end
      end
    end

    dispatcher = Noticent::Dispatcher.new(
      Noticent.configuration,
      :new_signup,
      payload
    )

    Noticent.configuration.opt_in_provider.opt_in(recipient_id: r1.id, scope: :post, entity_id: payload.post_id, alert_name: :new_signup, channel_name: :email)
    expect(Noticent.configuration.opt_in_provider.opted_in?(recipient_id: r1.id, scope: :post, entity_id: payload.post_id, alert_name: :new_signup, channel_name: :email)).to be_truthy

    dispatcher.dispatch
  end
end
