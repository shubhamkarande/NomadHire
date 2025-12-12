# frozen_string_literal: true

FactoryBot.define do
  factory :bid do
    association :job
    association :freelancer, factory: [:user, :freelancer]
    amount { rand(500..10000) }
    cover_letter { Faker::Lorem.paragraph(sentence_count: 8) }
    estimated_days { rand(7..60) }
    status { :pending }

    trait :pending do
      status { :pending }
    end

    trait :accepted do
      status { :accepted }
    end

    trait :declined do
      status { :declined }
    end

    trait :withdrawn do
      status { :withdrawn }
    end
  end
end
