# frozen_string_literal: true

require 'spec_helper'

describe ActAsNotified::Testing::InMemOptInProvider do
  it 'should store opt in' do
    provider = ActAsNotified::Testing::InMemOptInProvider.new
    provider.opt_in(scope: :s1, entity_id: 1, alert_name: :foo, channel_name: :email)
    expect(provider.opted_in?(scope: :s1, entity_id: 1, alert_name: :foo, channel_name: :email)).to be_truthy
    expect(provider.opted_in?(scope: :s2, entity_id: 1, alert_name: :foo, channel_name: :email)).not_to be_truthy
  end

  it 'should opt out' do
    provider = ActAsNotified::Testing::InMemOptInProvider.new
    provider.opt_in(scope: :s1, entity_id: 1, alert_name: :foo, channel_name: :email)

    expect(provider.opted_in?(scope: :s1, entity_id: 1, alert_name: :foo, channel_name: :email)).to be_truthy

    provider.opt_out(scope: :s1, entity_id: 1, alert_name: :foo, channel_name: :email)

    expect(provider.opted_in?(scope: :s1, entity_id: 1, alert_name: :foo, channel_name: :email)).not_to be_truthy
  end

  it 'shouldn\'t allow duplicates' do
    provider = ActAsNotified::Testing::InMemOptInProvider.new
    provider.opt_in(scope: :s1, entity_id: 1, alert_name: :foo, channel_name: :email)
    expect(provider.opted_in?(scope: :s1, entity_id: 1, alert_name: :foo, channel_name: :email)).to be_truthy
    provider.opt_in(scope: :s1, entity_id: 1, alert_name: :foo, channel_name: :email)
    expect(provider.opted_in?(scope: :s1, entity_id: 1, alert_name: :foo, channel_name: :email)).to be_truthy

    expect(provider.store.count).to eq(1)
  end
end
