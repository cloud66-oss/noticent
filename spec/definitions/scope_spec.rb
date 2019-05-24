# frozen_string_literal: true

require 'spec_helper'

describe Noticent::Definitions::Scope do
  it 'should construct a scope' do
    Noticent.configure {}
    expect { Noticent::Definitions::Scope.new(Noticent.configuration, :post) }.not_to raise_error
  end

  it 'should validate the scope class' do
    expect do
      Noticent.configure do
        scope :boo do
          alert :tfa_enabled
        end
      end
    end.not_to raise_error
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
