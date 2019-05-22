require 'spec_helper'

describe Noticent::ProcMap do
  it 'map works' do
    map = Noticent::ProcMap.new(Noticent::Config.new)
    map.use(:test, ->(payload) {return "here #{payload}"})

    expect(map.fetch(:test).call(:foo)).to eq('here foo')
    expect { map.use(:bar, -> { return 'there' }) }.to raise_error(Noticent::BadConfiguration)
    expect { map.fetch(:fes) }.to raise_error(Noticent::Error, "no map found for 'fes'")
  end
end
