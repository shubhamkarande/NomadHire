# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bid, type: :model do
  describe 'associations' do
    it { should belong_to(:job) }
    it { should belong_to(:freelancer).class_name('User') }
  end

  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:cover_letter) }
    it { should validate_length_of(:cover_letter).is_at_least(50).is_at_most(5000) }
    it { should validate_presence_of(:estimated_days) }
    it { should validate_numericality_of(:estimated_days).is_greater_than(0) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, withdrawn: 1, accepted: 2, declined: 3) }
  end

  describe '#accept!' do
    let(:client) { create(:user, role: :client) }
    let(:freelancer) { create(:user, role: :freelancer) }
    let(:job) { create(:job, client: client, status: :open) }
    let(:bid) { create(:bid, job: job, freelancer: freelancer, status: :pending) }
    let!(:other_bid) { create(:bid, job: job, status: :pending) }

    it 'changes bid status to accepted' do
      expect { bid.accept! }.to change { bid.reload.status }.from('pending').to('accepted')
    end

    it 'changes job status to in_progress' do
      bid.accept!
      expect(job.reload.status).to eq('in_progress')
    end

    it 'declines other pending bids' do
      bid.accept!
      expect(other_bid.reload.status).to eq('declined')
    end

    it 'creates a contract' do
      expect { bid.accept! }.to change { Contract.count }.by(1)
      contract = Contract.last
      expect(contract.freelancer).to eq(freelancer)
      expect(contract.client).to eq(client)
      expect(contract.total_amount).to eq(bid.amount)
    end

    it 'returns false if bid is not pending' do
      bid.update(status: :withdrawn)
      expect(bid.accept!).to be false
    end

    it 'returns false if job is not open' do
      job.update(status: :closed)
      expect(bid.accept!).to be false
    end
  end

  describe '#freelancer_cannot_be_client' do
    it 'is invalid if freelancer is the job client' do
      client = create(:user, role: :client)
      job = create(:job, client: client)
      bid = build(:bid, job: job, freelancer: client)
      
      expect(bid).not_to be_valid
      expect(bid.errors[:freelancer]).to include("cannot bid on their own job")
    end
  end
end
