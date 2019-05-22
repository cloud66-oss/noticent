# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Scope do

  it 'should construct a scope' do
    expect {Noticent::Scope.new(Noticent.configuration, :s1)}.not_to raise_error
  end

  it 'should construct a user scope object' do
    scope = Noticent::Scope.new(Noticent.configuration, :s1)
    expect(scope.instance).to be_a_kind_of(Noticent::Samples::S1)
  end

  it 'should support custom scope class' do
    class Boo
    end
    scope = Noticent::Scope.new(Noticent.configuration, :boo, klass: Boo)
    expect {scope.instance}.not_to raise_error
    expect(scope.instance).not_to be_nil
    expect(scope.instance).to be_a_kind_of(Boo)
  end

  it 'should support custom constructors' do
    class Boo
      def initialize(param); end
    end
    scope = Noticent::Scope.new(Noticent.configuration, :boo, klass: Boo, constructor: -> {Boo.new(:param)})
    expect {scope.instance}.not_to raise_error
    expect(scope.instance).not_to be_nil
    expect(scope.instance).to be_a_kind_of(Boo)
  end
end

