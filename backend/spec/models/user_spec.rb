# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:user_skills).dependent(:destroy) }
    it { should have_many(:skills).through(:user_skills) }
    it { should have_many(:posted_jobs).class_name('Job').dependent(:destroy) }
    it { should have_many(:bids).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { should validate_length_of(:bio).is_at_most(2000) }
    it { should allow_value(nil).for(:hourly_rate) }
    it { should validate_numericality_of(:hourly_rate).is_greater_than_or_equal_to(0).allow_nil }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(freelancer: 0, client: 1, admin: 2) }
  end

  describe '#can_post_jobs?' do
    it 'returns true for clients' do
      user = build(:user, role: :client)
      expect(user.can_post_jobs?).to be true
    end

    it 'returns true for admins' do
      user = build(:user, role: :admin)
      expect(user.can_post_jobs?).to be true
    end

    it 'returns false for freelancers' do
      user = build(:user, role: :freelancer)
      expect(user.can_post_jobs?).to be false
    end
  end

  describe '#can_bid?' do
    it 'returns true for freelancers' do
      user = build(:user, role: :freelancer)
      expect(user.can_bid?).to be true
    end

    it 'returns false for clients' do
      user = build(:user, role: :client)
      expect(user.can_bid?).to be false
    end
  end

  describe '#update_rating_cache!' do
    it 'calculates average rating from reviews' do
      user = create(:user, role: :freelancer)
      client = create(:user, role: :client)
      job = create(:job, client: client)
      
      # Create a mock contract scenario
      allow(user).to receive_message_chain(:reviews_received, :average).and_return(4.5)
      
      user.update_rating_cache!
      expect(user.rating_cache).to eq(4.5)
    end
  end
end
