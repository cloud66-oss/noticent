# frozen_string_literal: true

require 'spec_helper'

describe Noticent::View do

  it 'should require a valid file' do
    expect { Noticent::View.new('bad_file', binding_context: binding) }.to raise_error Noticent::ViewNotFound
  end

  it 'should render views with layout' do
    ch = Noticent::Channel.new([], {}, nil)
    view = Noticent::View.new(
        File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'sample_view.txt.erb')),
        template: File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'sample_layout.txt.erb')),
        binding_context: ch.get_binding
    )
    view.send(:parse)
    result = view.send(:render_content)
    expect(result).not_to be_nil
    expect(result).to be_a String
    expect(result).to include('Header', 'Footer', 'This is normal test')
  end

  it 'should render views without layout' do
    view = Noticent::View.new(
      File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'sample_view.txt.erb')),
      binding_context: binding
    )
    view.send(:parse)
    result = view.send(:render_content)
    expect(result).not_to be_nil
    expect(result).to be_a String
    expect(result).not_to include('Header', 'Footer')
    expect(result).to include('This is normal test')
  end


  it 'should detect frontmatter' do
    view = Noticent::View.new(
      File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'sample_view.txt')),
      binding_context: binding
    )
    view.send(:parse)

    expect(view.data_content).not_to be_nil
    expect(view.raw_content).not_to be_nil
  end

  it 'should be ok with no frontmatter' do
    view = Noticent::View.new(
      File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'no_frontmatter.txt')),
      binding_context: binding
    )
    view.send(:parse)

    expect(view.data_content).to be_nil
    expect(view.raw_content).not_to be_nil
  end

  it 'should read data' do
    view = Noticent::View.new(
      File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'no_frontmatter.txt')),
      binding_context: binding
    )
    view.send(:parse)
    view.send(:render_content)
    view.send(:read_data)

    expect(view.data).to be_nil
    expect(view.content).not_to be_nil

    view = Noticent::View.new(
      File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'sample_view.txt')),
      binding_context: binding
    )
    view.send(:parse)
    view.send(:render_data)
    view.send(:render_content)
    view.send(:read_data)
    expect(view.data).not_to be_nil
    expect(view.content).not_to be_nil
    expect(view.data[:foo]).to eq('bar')
    expect(view.content).to include('somethings is good --- here but')
  end

  it 'should process' do
    ch = Noticent::Channel.new([], Noticent::Samples::S1Payload.new, nil)
    view = Noticent::View.new(
        File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'sample_view.txt.erb')),
        template: File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', 'files', 'sample_layout.txt.erb')),
        binding_context: ch.get_binding
    )

    view.process

    expect(view.data).not_to be_nil
    expect(view.content).not_to be_nil
    expect(view.data[:foo]).to eq('bar')
    expect(view.content).to include('This is normal test')
    expect(view.data[:fuzz]).to eq('hello')
  end

end
