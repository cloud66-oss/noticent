require 'spec_helper'

describe ActAsNotified::Config do

  it 'is a hash' do
    config = ActAsNotified.configure { |config| nil }
    expect(config).to be_a_kind_of(ActAsNotified::Config)
  end

  it 'returns config' do
    ActAsNotified.configure do |config|
      config.for_payloads do
        use(:foo, ->(payload) { return :foo })
        use(:bar, ->(payload) { return :bar })
      end
    end

    expect(ActAsNotified.configuration).to be_a_kind_of(ActAsNotified::Config)
    expect(ActAsNotified.configuration.payloads).not_to be_nil
    expect(ActAsNotified.configuration.payloads.count).to eq(2)
  end

  it 'has payload_as' do
    ActAsNotified.configure do |config|
      config.for_payloads do
        # do something
      end
    end
  end

  it 'build payload map' do
    payloads = nil
    ActAsNotified.configure do |config|
      payloads = config.for_payloads do
        use(:test, ->(payload) { return payload })
      end
    end

    expect(payloads).not_to be_nil
    expect(payloads.fetch(:test)).to be_a_kind_of Proc
    result = payloads.fetch(:test).call('built payload map')
    expect(result).to eq('built payload map')
  end

  it 'build scopers map' do
    scopers = nil
    ActAsNotified.configure do |config|
      scopers = config.for_scopes do
        use(:test, ->(payload) { return payload })
      end
    end

    expect(scopers).not_to be_nil
    expect(scopers.fetch(:test)).to be_a_kind_of Proc
    result = scopers.fetch(:test).call('built scopers map')
    expect(result).to eq('built scopers map')
  end

  it 'build recipents map' do
    recipients = nil
    another = nil
    ActAsNotified.configure do |config|
      recipients = config.recipients(:owner) do
        use(:test, ->(payload) { return payload })
      end
      another = config.recipients(:buyer) do
        use(:test, ->(payload) { return payload })
      end
    end

    expect(recipients).not_to be_nil
    expect(recipients.fetch(:test)).to be_a_kind_of Proc
    result = recipients.fetch(:test).call('built recipients map')
    expect(result).to eq('built recipients map')
    expect(ActAsNotified.configuration.recipients[:owner]).to equal(recipients)
    expect(ActAsNotified.configuration.recipients[:buyer]).to equal(another)
  end

  it 'setup scope alias' do
    ActAsNotified.configure do |config|
      config.scope_alias(foo: :bar, fuzz: :buzz)
    end

    expect(ActAsNotified.configuration.aliases).to be_a_kind_of Hash
    expect(ActAsNotified.configuration.aliases[:foo]).to eq(:bar)
  end

end