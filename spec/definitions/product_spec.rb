# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Definitions::Product do
  it 'can be created' do
    Noticent.configure
    product = Noticent::Definitions::Product.new(Noticent.configuration, :foo)

    expect(product).not_to be_nil
  end

  it 'should only accept symbol names' do
    Noticent.configure
    expect { Noticent::Definitions::Product.new(Noticent.configuration, 'foo') }.to raise_error Noticent::BadConfiguration
  end

end
