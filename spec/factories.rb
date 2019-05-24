# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :recipient, class: Noticent::Testing::Recipient do
    email { generate(:email) }
  end

  factory :post, class: Noticent::Testing::Post do
    sequence :id
  end

  factory :post_payload, class: Noticent::Testing::PostPayload do
  end

end
