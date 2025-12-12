# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Job, type: :model do
  describe 'associations' do
    it { should belong_to(:client).class_name('User') }
    it { should have_many(:job_skills).dependent(:destroy) }
    it { should have_many(:skills).through(:job_skills) }
    it { should have_many(:bids).dependent(:destroy) }
    it { should have_one(:contract).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_least(10).is_at_most(200) }
    it { should validate_presence_of(:description) }
    it { should validate_length_of(:description).is_at_least(50).is_at_most(10000) }
    it { should validate_presence_of(:budget_min) }
    it { should validate_numericality_of(:budget_min).is_greater_than(0) }
    it { should validate_presence_of(:deadline) }
  end

  describe 'enums' do
    it { should define_enum_for(:budget_type).with_values(fixed: 0, hourly: 1) }
    it { should define_enum_for(:status).with_values(open: 0, in_progress: 1, completed: 2, closed: 3, cancelled: 4) }
  end

  describe 'scopes' do
    let!(:client) { create(:user, role: :client) }
    let!(:open_job) { create(:job, client: client, status: :open) }
    let!(:closed_job) { create(:job, client: client, status: :closed) }

    describe '.active' do
      it 'returns only open jobs' do
        expect(Job.active).to include(open_job)
        expect(Job.active).not_to include(closed_job)
      end
    end

    describe '.search' do
      it 'searches by title' do
        job = create(:job, client: client, title: 'Build a React application')
        expect(Job.search('React')).to include(job)
        expect(Job.search('Angular')).not_to include(job)
      end
    end
  end

  describe '#budget_range' do
    it 'returns range when both min and max exist' do
      job = build(:job, budget_min: 1000, budget_max: 2000)
      expect(job.budget_range).to eq('1000 - 2000')
    end

    it 'returns just min when no max' do
      job = build(:job, budget_min: 1000, budget_max: nil)
      expect(job.budget_range).to eq('1000')
    end
  end

  describe '#deadline_must_be_future' do
    it 'is invalid with past deadline on create' do
      job = build(:job, deadline: 1.day.ago)
      expect(job).not_to be_valid
      expect(job.errors[:deadline]).to include("must be in the future")
    end

    it 'is valid with future deadline' do
      job = build(:job, deadline: 1.week.from_now)
      expect(job).to be_valid
    end
  end
end
