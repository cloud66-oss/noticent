require 'act_as_notified/config'

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
        puts 'payload'
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

end