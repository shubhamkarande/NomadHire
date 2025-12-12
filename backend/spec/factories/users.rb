# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { :freelancer }
    bio { Faker::Lorem.paragraph(sentence_count: 3) }
    hourly_rate { rand(25..150) }
    location { "#{Faker::Address.city}, #{Faker::Address.state_abbr}" }
    rating_cache { rand(3.5..5.0).round(1) }

    trait :client do
      role { :client }
    end

    trait :freelancer do
      role { :freelancer }
    end

    trait :admin do
      role { :admin }
    end
  end
end
