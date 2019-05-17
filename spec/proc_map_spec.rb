require 'spec_helper'

describe ActAsNotified::ProcMap do

  it 'map works' do
    map = ActAsNotified::ProcMap.new(ActAsNotified::Config.new)
    map.use(:test, ->(payload) { return "here #{payload}" })


    expect(map.fetch(:test).call(:foo)).to eq('here foo')
    expect { map.use(:bar, -> { return 'there' }) }.to raise_error(ActAsNotified::BadConfiguration)
    expect { map.fetch(:fes) }.to raise_error(ActAsNotified::Error, "no map found for 'fes'")
  end

end
