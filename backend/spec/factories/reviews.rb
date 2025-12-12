FactoryBot.define do
  factory :review do
    reviewer { nil }
    reviewed_user { nil }
    contract { nil }
    rating { 1 }
    comment { "MyText" }
  end
end
