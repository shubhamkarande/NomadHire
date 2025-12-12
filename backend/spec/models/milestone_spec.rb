# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Milestone, type: :model do
  describe 'associations' do
    it { should belong_to(:contract) }
    it { should have_many(:transactions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_least(3).is_at_most(200) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:due_date) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(pending: 0, paid: 1, delivered: 2, released: 3, failed: 4, disputed: 5) }
  end

  describe '#pay!' do
    let(:milestone) { create(:milestone, status: :pending) }

    it 'updates status to paid' do
      expect(milestone.pay!(provider: 'stripe', payment_intent_id: 'pi_test_123')).to be true
      expect(milestone.reload.status).to eq('paid')
    end

    it 'creates a transaction' do
      expect {
        milestone.pay!(provider: 'stripe', payment_intent_id: 'pi_test_123')
      }.to change { Transaction.count }.by(1)
    end

    it 'returns false if not pending' do
      milestone.update(status: :paid)
      expect(milestone.pay!(provider: 'stripe', payment_intent_id: 'pi_test_123')).to be false
    end
  end

  describe '#mark_delivered!' do
    it 'updates status from paid to delivered' do
      milestone = create(:milestone, status: :paid)
      expect(milestone.mark_delivered!).to be true
      expect(milestone.reload.status).to eq('delivered')
    end

    it 'returns false if not paid' do
      milestone = create(:milestone, status: :pending)
      expect(milestone.mark_delivered!).to be false
    end
  end

  describe '#release!' do
    let(:contract) { create(:contract, status: :active) }
    let(:milestone) { create(:milestone, contract: contract, status: :delivered) }

    it 'updates status to released' do
      expect(milestone.release!).to be true
      expect(milestone.reload.status).to eq('released')
    end

    it 'returns false if not delivered or paid' do
      milestone = create(:milestone, status: :pending)
      expect(milestone.release!).to be false
    end
  end

  describe '#overdue?' do
    it 'returns true if past due date and not released' do
      milestone = build(:milestone, due_date: 1.day.ago, status: :paid)
      expect(milestone.overdue?).to be true
    end

    it 'returns false if released' do
      milestone = build(:milestone, due_date: 1.day.ago, status: :released)
      expect(milestone.overdue?).to be false
    end

    it 'returns false if due date is in future' do
      milestone = build(:milestone, due_date: 1.day.from_now)
      expect(milestone.overdue?).to be false
    end
  end
end
