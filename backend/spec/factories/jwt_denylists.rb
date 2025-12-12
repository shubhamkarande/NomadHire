FactoryBot.define do
  factory :jwt_denylist do
    jti { "MyString" }
    exp { "2025-12-12 11:58:35" }
  end
end
