# frozen_string_literal: true

FactoryBot.define do
  factory :contract do
    association :job, :in_progress
    association :client, factory: [:user, :client]
    association :freelancer, factory: [:user, :freelancer]
    total_amount { rand(1000..20000) }
    status { :active }

    trait :active do
      status { :active }
    end

    trait :completed do
      status { :completed }
    end

    trait :cancelled do
      status { :cancelled }
    end
  end
end
