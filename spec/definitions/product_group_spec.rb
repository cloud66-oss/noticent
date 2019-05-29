# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Definitions::ProductGroup do
  it 'can be created' do
    Noticent.configure

    pg = Noticent::Definitions::ProductGroup.new(Noticent.configuration)

    expect(pg).not_to be_nil
  end

  it 'should build up' do
    Noticent.configure do
      product :foo
      product :bar
    end

    pg = Noticent::Definitions::ProductGroup.new(Noticent.configuration)
    pg.to(:foo)

    # add it again
    expect { pg.to(:foo) }.to raise_error Noticent::BadConfiguration

    expect(pg.products.count).to eq(1)

    pg.to(:bar)

    expect(pg.products.count).to eq(2)

    # not_to a bad one
    expect { pg.not_to(:fuzz) }.to raise_error Noticent::BadConfiguration
    expect(pg.products.count).to eq(2)
  end

  it 'should not_to' do
    Noticent.configure do
      product :foo
      product :bar
      product :fuzz
    end

    pg = Noticent::Definitions::ProductGroup.new(Noticent.configuration)

    # not_to a good one
    pg.not_to(:bar)

    expect(pg.products.count).to eq(2)
    expect(pg.products.keys).to eq(%i[foo fuzz])
    expect(pg.products[:foo]).to be_a Noticent::Definitions::Product
    expect(pg.products[:fuzz]).to be_a Noticent::Definitions::Product
  end
end
