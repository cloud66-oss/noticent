# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence(:id) do |n|
    n
  end

  factory :recipient, class: Noticent::Testing::Recipient do
    email { generate(:email) }
  end

  factory :post_payload, class: Noticent::Testing::PostPayload do
    post_id { generate(:id) }
  end

  factory :comment_payload, class: Noticent::Testing::CommentPayload do
    comment_id { generate(:id) }
  end

end
