# frozen_string_literal: true

FactoryBot.define do
  factory :milestone do
    association :contract
    title { Faker::Lorem.sentence(word_count: 4) }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    amount { rand(250..2500) }
    due_date { rand(7..30).days.from_now }
    status { :pending }

    trait :pending do
      status { :pending }
    end

    trait :paid do
      status { :paid }
    end

    trait :delivered do
      status { :delivered }
    end

    trait :released do
      status { :released }
    end
  end
end
