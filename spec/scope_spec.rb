# frozen_string_literal: true

require 'spec_helper'

describe ActAsNotified::Scope do

  it 'should construct a scope' do
    expect {ActAsNotified::Scope.new(ActAsNotified.configuration, :s1)}.not_to raise_error
  end

  it 'should construct a user scope object' do
    scope = ActAsNotified::Scope.new(ActAsNotified.configuration, :s1)
    expect(scope.instance).to be_a_kind_of(ActAsNotified::Samples::S1)
  end

  it 'should support custom scope class' do
    class Boo
    end
    scope = ActAsNotified::Scope.new(ActAsNotified.configuration, :boo, klass: Boo)
    expect {scope.instance}.not_to raise_error
    expect(scope.instance).not_to be_nil
    expect(scope.instance).to be_a_kind_of(Boo)
  end

  it 'should support custom constructors' do
    class Boo
      def initialize(param); end
    end
    scope = ActAsNotified::Scope.new(ActAsNotified.configuration, :boo, klass: Boo, constructor: -> {Boo.new(:param)})
    expect {scope.instance}.not_to raise_error
    expect(scope.instance).not_to be_nil
    expect(scope.instance).to be_a_kind_of(Boo)
  end
end

