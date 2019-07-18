# frozen_string_literal: true

require "spec_helper"

describe Noticent::ActiveRecordOptInProvider do
  it "opt in" do
    Noticent::OptIn.delete_all

    provider = Noticent::ActiveRecordOptInProvider.new

    provider.opt_in(recipient_id: 1, scope: :test, alert_name: :foo, entity_id: 10, channel_name: :email)
    expect(Noticent::OptIn.all.count).to eq(1)

    provider.opt_in(recipient_id: 1, scope: :test, alert_name: :foo, entity_id: 20, channel_name: :email)
    expect(Noticent::OptIn.all.count).to eq(2)
  end

  it "add new alert types" do
    Noticent::OptIn.delete_all

    provider = Noticent::ActiveRecordOptInProvider.new

    provider.opt_in(recipient_id: 1, scope: :test, alert_name: :foo, entity_id: 10, channel_name: :email)
    provider.opt_in(recipient_id: 1, scope: :test, alert_name: :foo, entity_id: 20, channel_name: :email)
    provider.opt_in(recipient_id: 2, scope: :test, alert_name: :foo, entity_id: 30, channel_name: :email)

    provider.add_alert(scope: :test, alert_name: :bar, recipient_ids: [1, 2, 3], channel: :email)

    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 10, alert_name: :bar, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 20, alert_name: :bar, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 2, scope: :test, entity_id: 30, alert_name: :bar, channel_name: :email)).to be_truthy

    provider.add_alert(scope: :test, alert_name: :bar, recipient_ids: [5, 6], channel: :email)

    expect(provider.opted_in?(recipient_id: 5, scope: :test, entity_id: 10, alert_name: :bar, channel_name: :email)).not_to be_truthy
    expect(provider.opted_in?(recipient_id: 6, scope: :test, entity_id: 20, alert_name: :bar, channel_name: :email)).not_to be_truthy

    provider.add_alert(scope: :test, alert_name: :fuzz, recipient_ids: [1, 2, 3, 5, 6], channel: :email)

    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 10, alert_name: :fuzz, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 20, alert_name: :fuzz, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 2, scope: :test, entity_id: 30, alert_name: :fuzz, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 5, scope: :test, entity_id: 10, alert_name: :fuzz, channel_name: :email)).not_to be_truthy
    expect(provider.opted_in?(recipient_id: 6, scope: :test, entity_id: 20, alert_name: :fuzz, channel_name: :email)).not_to be_truthy
  end

  it "should remove an alert" do
    Noticent::OptIn.delete_all

    provider = Noticent::ActiveRecordOptInProvider.new

    provider.opt_in(recipient_id: 1, scope: :test, alert_name: :foo, entity_id: 10, channel_name: :email)
    provider.opt_in(recipient_id: 2, scope: :test, alert_name: :foo, entity_id: 20, channel_name: :email)
    provider.opt_in(recipient_id: 3, scope: :test, alert_name: :foo, entity_id: 30, channel_name: :email)

    provider.opt_in(recipient_id: 1, scope: :test, alert_name: :bar, entity_id: 10, channel_name: :email)
    provider.opt_in(recipient_id: 2, scope: :test, alert_name: :bar, entity_id: 20, channel_name: :email)
    provider.opt_in(recipient_id: 3, scope: :test, alert_name: :bar, entity_id: 30, channel_name: :email)

    provider.remove_alert(scope: :test, alert_name: :foo)

    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 10, alert_name: :foo, channel_name: :email)).not_to be_truthy
    expect(provider.opted_in?(recipient_id: 2, scope: :test, entity_id: 20, alert_name: :foo, channel_name: :email)).not_to be_truthy
    expect(provider.opted_in?(recipient_id: 3, scope: :test, entity_id: 30, alert_name: :foo, channel_name: :email)).not_to be_truthy

    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 10, alert_name: :bar, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 2, scope: :test, entity_id: 20, alert_name: :bar, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 3, scope: :test, entity_id: 30, alert_name: :bar, channel_name: :email)).to be_truthy
  end

  it "should opt out" do
    Noticent::OptIn.delete_all

    provider = Noticent::ActiveRecordOptInProvider.new

    provider.opt_in(recipient_id: 1, scope: :test, alert_name: :foo, entity_id: 10, channel_name: :email)
    provider.opt_in(recipient_id: 2, scope: :test, alert_name: :foo, entity_id: 20, channel_name: :email)
    provider.opt_in(recipient_id: 3, scope: :test, alert_name: :foo, entity_id: 30, channel_name: :email)

    provider.opt_in(recipient_id: 1, scope: :test, alert_name: :bar, entity_id: 10, channel_name: :email)
    provider.opt_in(recipient_id: 2, scope: :test, alert_name: :bar, entity_id: 20, channel_name: :email)
    provider.opt_in(recipient_id: 3, scope: :test, alert_name: :bar, entity_id: 30, channel_name: :email)

    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 10, alert_name: :foo, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 2, scope: :test, entity_id: 20, alert_name: :foo, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 3, scope: :test, entity_id: 30, alert_name: :foo, channel_name: :email)).to be_truthy

    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 10, alert_name: :bar, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 2, scope: :test, entity_id: 20, alert_name: :bar, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 3, scope: :test, entity_id: 30, alert_name: :bar, channel_name: :email)).to be_truthy

    provider.opt_out(recipient_id: 1, scope: :test, alert_name: :foo, entity_id: 10, channel_name: :email)

    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 10, alert_name: :foo, channel_name: :email)).not_to be_truthy
    expect(provider.opted_in?(recipient_id: 2, scope: :test, entity_id: 20, alert_name: :foo, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 3, scope: :test, entity_id: 30, alert_name: :foo, channel_name: :email)).to be_truthy

    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 10, alert_name: :bar, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 2, scope: :test, entity_id: 20, alert_name: :bar, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 3, scope: :test, entity_id: 30, alert_name: :bar, channel_name: :email)).to be_truthy
  end
  
  it 'should remove an entity' do
    Noticent::OptIn.delete_all

    provider = Noticent::ActiveRecordOptInProvider.new

    provider.opt_in(recipient_id: 1, scope: :test, alert_name: :foo, entity_id: 10, channel_name: :email)
    provider.opt_in(recipient_id: 2, scope: :test, alert_name: :foo, entity_id: 20, channel_name: :email)
    provider.opt_in(recipient_id: 3, scope: :test, alert_name: :foo, entity_id: 30, channel_name: :email)

    provider.opt_in(recipient_id: 1, scope: :test, alert_name: :bar, entity_id: 10, channel_name: :email)
    provider.opt_in(recipient_id: 2, scope: :test, alert_name: :bar, entity_id: 20, channel_name: :email)
    provider.opt_in(recipient_id: 3, scope: :test, alert_name: :bar, entity_id: 30, channel_name: :email)

    provider.remove_entity(scope: :test, entity_id: 10)

    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 10, alert_name: :foo, channel_name: :email)).not_to be_truthy
    expect(provider.opted_in?(recipient_id: 2, scope: :test, entity_id: 20, alert_name: :foo, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 3, scope: :test, entity_id: 30, alert_name: :foo, channel_name: :email)).to be_truthy

    expect(provider.opted_in?(recipient_id: 1, scope: :test, entity_id: 10, alert_name: :bar, channel_name: :email)).not_to be_truthy
    expect(provider.opted_in?(recipient_id: 2, scope: :test, entity_id: 20, alert_name: :bar, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(recipient_id: 3, scope: :test, entity_id: 30, alert_name: :bar, channel_name: :email)).to be_truthy
  end
end
