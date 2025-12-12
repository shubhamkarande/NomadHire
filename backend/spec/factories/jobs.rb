# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    association :client, factory: [:user, :client]
    title { "Build a #{Faker::ProgrammingLanguage.name} Application" }
    description { Faker::Lorem.paragraph(sentence_count: 10) }
    budget_min { rand(500..5000) }
    budget_max { budget_min + rand(1000..5000) }
    budget_type { [:fixed, :hourly].sample }
    deadline { rand(14..90).days.from_now }
    status { :open }

    trait :fixed do
      budget_type { :fixed }
    end

    trait :hourly do
      budget_type { :hourly }
    end

    trait :open do
      status { :open }
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
    end

    trait :closed do
      status { :closed }
    end
  end
end
