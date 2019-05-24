# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Definitions::Scope do
  it 'should construct a scope' do
    Noticent.configure {}
    expect { Noticent::Definitions::Scope.new(Noticent.configuration, :post) }.not_to raise_error
  end

  it 'should construct a user scope object' do
    scope = Noticent::Definitions::Scope.new(Noticent.configuration, :post)
    expect(scope.instance).to be_a_kind_of(Noticent::Testing::Post)
  end

  it 'should support custom scope class' do
    class Boo
    end
    scope = Noticent::Definitions::Scope.new(Noticent.configuration, :boo, klass: Boo)
    expect { scope.instance }.not_to raise_error
    expect(scope.instance).not_to be_nil
    expect(scope.instance).to be_a_kind_of(Boo)
  end

  it 'should support custom constructors' do
    class Boo
      def initialize(param); end
    end
    scope = Noticent::Definitions::Scope.new(Noticent.configuration, :boo, klass: Boo, constructor: -> { Boo.new(:param) })
    expect { scope.instance }.not_to raise_error
    expect(scope.instance).not_to be_nil
    expect(scope.instance).to be_a_kind_of(Boo)
  end

  it 'should validate during construction' do
    Noticent.configure
    expect { Noticent::Definitions::Scope.new(Noticent.configuration, :do) }.to raise_error Noticent::BadConfiguration
  end

  it 'should validate the scope class' do
    expect do
      Noticent.configure do
        scope :boo do
          alert :tfa_enabled
        end
      end
    end.not_to raise_error

    expect do
      Noticent.configure do
        scope :post do
          alert :tfa_enabled do
            notify :staff
          end
        end
      end
    end.to raise_error Noticent::BadConfiguration
  end

  it 'should raise error with bad class' do
    expect do
      Noticent.configure do
        scope :boo do
          alert :tfa_enabled do
            notify :users
          end
        end
      end
    end.to raise_error Noticent::BadConfiguration
  end

  it 'should have an id attribute' do
    class BadScope; attr_accessor :users; end

    expect do
      Noticent.configure do
        scope :bad_scope, klass: BadScope do
          alert :foo do
            notify :users
          end
        end
      end
    end.to raise_error Noticent::BadConfiguration
  end

  it 'should support validation of payload classes' do
    Noticent.configure do
      scope :post, payload_class: Noticent::Testing::PostPayload do
      end
    end

    expect do
      Noticent.configure do
        scope :post, payload_class: Noticent::Testing::CommentPayload do
        end
      end
    end.to raise_error Noticent::BadConfiguration
  end

end
