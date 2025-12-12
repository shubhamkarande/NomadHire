FactoryBot.define do
  factory :notification do
    user { nil }
    kind { "MyString" }
    payload { "" }
    read { false }
  end
end
