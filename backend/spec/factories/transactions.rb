FactoryBot.define do
  factory :transaction do
    milestone { nil }
    client { nil }
    amount { "9.99" }
    provider { 1 }
    provider_payment_id { "MyString" }
    status { 1 }
  end
end
