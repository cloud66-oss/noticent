# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Config do
  it 'is configured' do
    Noticent.configure {}
    expect(Noticent.configuration.opt_in_provider).not_to be_nil
  end

  it 'should be configurable' do
    ENV['NOTICENT_RSPEC'] = '0'
    Noticent.configure do |config|
      config.base_dir = 'foo'
      config.base_module_name = 'Noticent::Foo'
    end

    expect(Noticent.configuration.base_dir).to eq('foo')
    ENV['NOTICENT_RSPEC'] = '1'
  end

  it 'is a hash' do
    config = Noticent.configure { |_config| nil }
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
    expect(hooks).to be_a_kind_of(Noticent::Definitions::Hooks)
  end

  it 'channel hooks should be addable' do
    class Hook
      def pre_channel_registration; end

      def post_channel_registration; end
    end

    h1 = Hook.new
    h2 = Hook.new
    h3 = Hook.new

    Noticent.configure do |config|
      config.hooks.add(:pre_channel_registration, h1)
      config.hooks.add(:post_channel_registration, h2)
      config.hooks.add(:pre_channel_registration, h3)
    end

    expect(Noticent.configuration.hooks).not_to be_nil
    expect(Noticent.configuration.hooks.send(:storage).count).to eq(2)
    expect(Noticent.configuration.hooks.send(:storage)[:pre_channel_registration].count).to eq(2)
    expect(Noticent.configuration.hooks.send(:storage)[:post_channel_registration].count).to eq(1)
    expect(Noticent.configuration.hooks.send(:storage)[:pre_channel_registration]).to include(h1, h3)
    expect(Noticent.configuration.hooks.send(:storage)[:post_channel_registration]).to include(h2)
    expect(Noticent.configuration.hooks.fetch(:post_channel_registration)).to include(h2)
    expect(Noticent.configuration.hooks.fetch(:pre_channel_registration)).to include(h1, h3)
    expect { Noticent.configuration.hooks.add(:bad_hook, String) }.to raise_error(Noticent::BadConfiguration)
  end

  it 'should have channel' do
    Noticent.configure do |config|
      config.channel(:email, klass: ::Noticent::Testing::Email) {}
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

  it 'should find channel groups' do
    Noticent.configure do
      channel :email
      channel :slack
      channel :webhook, group: :internal
      channel :boo, group: :internal
      channel :foo, group: :private
    end

    expect(Noticent.configuration.channels.count).to eq(5)
    expect(Noticent.configuration.channel_groups.count).to eq(3)
  end

  it 'should find alert channels' do
    Noticent.configure do
      channel :email
      channel :slack
      channel :webhook, group: :internal
      channel :boo, group: :internal
      channel :foo, group: :private

      scope :post do
        alert :foo do
          notify(:users).on(:default)
          notify(:owners).on(:internal)
        end

        alert :boo do
          notify(:users).on(:private)
        end
      end
    end

    expect(Noticent.configuration.alert_channels(:foo).map(&:name)).to eq(%i[email slack webhook boo])
    expect(Noticent.configuration.alert_channels(:boo).map(&:name)).to eq([:foo])
  end

  it 'should check for alert name methods on channel' do
    expect do
      Noticent.configure do
        channel :email
        channel :slack
        channel :webhook, group: :internal
        channel :boo, group: :internal
        channel :foo, group: :private

        scope :post do
          alert :bad_alert do
            notify(:users).on(:default)
            notify(:owners).on(:internal)
          end
        end
      end
    end.to raise_error Noticent::BadConfiguration
  end

  it 'should find alerts by scope' do
    Noticent.configure do
      scope :post do
        alert :one do
          notify :users
        end

        alert :two do
          notify :users
        end
      end

      scope :comment do
        alert :three do
          notify :users
        end
      end
    end

    expect(Noticent.configuration.alerts_by_scope(:post)).not_to be_nil
    expect(Noticent.configuration.alerts_by_scope(:post).count).to eq(2)
    expect(Noticent.configuration.alerts_by_scope(:post).map(&:name)).to eq(%i[one two])
    expect(Noticent.configuration.alerts_by_scope(:comment).map(&:name)).to eq([:three])
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

  it 'should define a scope' do
    Noticent.configure do
      scope :post do
      end
    end
  end

  it 'should have scopes and alerts' do
    expect do
      Noticent.configure do
        scope :post do
          alert(:tfa_enabled) { notify :users }
          alert(:sign_up) { notify :users }
        end
      end
    end.not_to raise_error

    expect(Noticent.configuration.scopes).not_to be_nil
    expect(Noticent.configuration.scopes.count).to eq(1)
    expect(Noticent.configuration.scopes[:post]).not_to be_nil
    expect(Noticent.configuration.alerts).not_to be_nil
    expect(Noticent.configuration.scopes[:bad]).to be_nil
    expect(Noticent.configuration.alerts.count).to eq(2)
    expect(Noticent.configuration.alerts[:tfa_enabled].name).to eq(:tfa_enabled)
    expect(Noticent.configuration.alerts[:tfa_enabled].scope.name).to eq(:post)
  end

  it 'should force alert uniqueness across scopes' do
    expect do
      Noticent.configure do
        scope :post do
          alert(:a1) {}
        end
        scope :comment do
          alert(:a1) {}
        end
      end
    end.to raise_error(Noticent::BadConfiguration)
  end

  it 'should handle bad notifications' do
    Noticent.configure do
      scope :post do
        alert(:boo) { notify :users }
      end
    end
    expect { Noticent.notify('hello', {}) }.to raise_error(Noticent::InvalidAlert)
    payload = build(:post_payload)
    expect { Noticent.notify(:bar, payload) }.to raise_error(Noticent::InvalidAlert)
  end

  it 'should find the right alert' do
    Noticent.configure do
      scope :post do
        alert(:foo) { notify :users }
      end
    end

    p1 = build(:post_payload)
    expect { Noticent.notify(:foo, p1) }.not_to raise_error
    expect { Noticent.notify(:bar, p1) }.to raise_error(Noticent::InvalidAlert)
  end

  it 'should dispatch' do
    Noticent.configure do
      channel(:email) {}
      scope :post do
        alert(:new_signup) do
          notify(:users)
        end
      end
    end

    rec = create_list(:recipient, 3)
    p1 = build(:post_payload, _users: rec)
    Noticent.notify(:new_signup, p1)
  end

  it 'should support products' do
    Noticent.configure do
      product :foo
      product :bar
      product :puck

      scope :post do
        alert :fuzz do
          applies.to :foo
          applies.to :bar
          notify :users
        end

        alert :buzz do
          applies.not_to :bar
          notify :users
        end
      end
    end

    expect(Noticent.configuration.products.count).to eq(3)
    expect(Noticent.configuration.alerts[:fuzz].products.count).to eq(2)
    expect(Noticent.configuration.alerts[:buzz].products.count).to eq(2)
    expect(Noticent.configuration.alerts[:fuzz].products.keys).to eq(%i[foo bar])
    expect(Noticent.configuration.alerts[:buzz].products.keys).to eq(%i[foo puck])

    expect(Noticent.configuration.products_by_alert(:fuzz).keys).to eq(%i[foo bar])
    expect(Noticent.configuration.products_by_alert(:buzz).keys).to eq(%i[foo puck])
  end

  it 'should setup a new recipient' do
    Noticent.configure do
      channel :email
      channel :slack

      scope :post do
        alert :foo do
          notify :users
          default true
          default(false) { on(:slack) }
        end
      end
    end

    Noticent.setup_recipient(recipient_id: 1, scope: :post, entity_ids: [2])

    expect(Noticent.configuration.opt_in_provider.opted_in?(recipient_id: 1, scope: :post, entity_id: 2, alert_name: :foo, channel_name: :email)).to be_truthy
    expect(Noticent.configuration.opt_in_provider.opted_in?(recipient_id: 2, scope: :post, entity_id: 2, alert_name: :foo, channel_name: :email)).not_to be_truthy
    expect(Noticent.configuration.opt_in_provider.opted_in?(recipient_id: 1, scope: :post, entity_id: 2, alert_name: :foo, channel_name: :slack)).not_to be_truthy
  end

end
