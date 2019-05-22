# frozen_string_literal: true

require 'spec_helper'

describe Noticent::View do

  it 'should require a valid file' do
    expect { Noticent::View.new('bad_file') }.to raise_error Noticent::ViewNotFound
  end

  it 'should detect frontmatter' do
    view = Noticent::View.new(File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'sample_view.txt')))
    loaded = view.send(:parse)
    expect(loaded).not_to be_nil
    expect(loaded).to be_a_kind_of Hash
    expect(loaded[:frontmatter]).not_to be_nil
    expect(loaded[:content]).not_to be_nil
  end

  it 'should be ok with no frontmatter' do
    view = Noticent::View.new(File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'no_frontmatter.txt')))
    loaded = view.send(:parse)
    expect(loaded).not_to be_nil
    expect(loaded).to be_a_kind_of Hash
    expect(loaded[:frontmatter]).to be_nil
    expect(loaded[:content]).not_to be_nil
  end

  it 'should load all data' do
    view = Noticent::View.new(File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'sample_view.txt')))

    expect(view.data?).to be_truthy
    expect(view.content).not_to be_nil
    expect(view.data).not_to be_nil
    expect(view.data[:foo]).to eq('bar')
  end
end
