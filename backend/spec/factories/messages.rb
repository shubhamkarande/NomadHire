FactoryBot.define do
  factory :message do
    conversation { nil }
    sender { nil }
    body { "MyText" }
    read_at { "2025-12-12 11:57:58" }
  end
end
