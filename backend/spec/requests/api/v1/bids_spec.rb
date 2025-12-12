# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Bids', type: :request do
  include_context 'authenticated user'

  describe 'POST /api/v1/jobs/:job_id/bids' do
    let(:client) { create(:user, :client) }
    let(:freelancer) { create(:user, :freelancer) }
    let(:job) { create(:job, client: client, status: :open) }
    let(:valid_params) do
      {
        bid: {
          amount: 5000,
          cover_letter: 'I am an experienced developer and would love to work on this project. I have completed similar projects before and can deliver high-quality results.',
          estimated_days: 30
        }
      }
    end

    context 'as a freelancer' do
      it 'creates a bid' do
        expect {
          post "/api/v1/jobs/#{job.id}/bids", params: valid_params, headers: auth_headers(freelancer)
        }.to change(Bid, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end

      it 'prevents duplicate bids' do
        create(:bid, job: job, freelancer: freelancer)
        
        post "/api/v1/jobs/#{job.id}/bids", params: valid_params, headers: auth_headers(freelancer)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'as a client' do
      it 'returns forbidden' do
        post "/api/v1/jobs/#{job.id}/bids", params: valid_params, headers: auth_headers(client)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/bids/:id/accept' do
    let(:client) { create(:user, :client) }
    let(:freelancer) { create(:user, :freelancer) }
    let(:job) { create(:job, client: client, status: :open) }
    let(:bid) { create(:bid, job: job, freelancer: freelancer, status: :pending) }

    context 'as the job owner' do
      it 'accepts the bid' do
        post "/api/v1/bids/#{bid.id}/accept", headers: auth_headers(client)
        
        expect(response).to have_http_status(:ok)
        expect(bid.reload.status).to eq('accepted')
      end

      it 'creates a contract' do
        expect {
          post "/api/v1/bids/#{bid.id}/accept", headers: auth_headers(client)
        }.to change(Contract, :count).by(1)
      end

      it 'returns the contract' do
        post "/api/v1/bids/#{bid.id}/accept", headers: auth_headers(client)
        
        body = JSON.parse(response.body)
        expect(body).to have_key('contract')
      end
    end

    context 'as non-owner' do
      let(:other_client) { create(:user, :client) }

      it 'returns forbidden' do
        post "/api/v1/bids/#{bid.id}/accept", headers: auth_headers(other_client)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'POST /api/v1/bids/:id/decline' do
    let(:client) { create(:user, :client) }
    let(:job) { create(:job, client: client) }
    let(:bid) { create(:bid, job: job, status: :pending) }

    it 'declines the bid' do
      post "/api/v1/bids/#{bid.id}/decline", headers: auth_headers(client)
      
      expect(response).to have_http_status(:ok)
      expect(bid.reload.status).to eq('declined')
    end
  end

  describe 'POST /api/v1/bids/:id/withdraw' do
    let(:freelancer) { create(:user, :freelancer) }
    let(:bid) { create(:bid, freelancer: freelancer, status: :pending) }

    it 'withdraws the bid' do
      post "/api/v1/bids/#{bid.id}/withdraw", headers: auth_headers(freelancer)
      
      expect(response).to have_http_status(:ok)
      expect(bid.reload.status).to eq('withdrawn')
    end

    context 'as non-owner' do
      let(:other_freelancer) { create(:user, :freelancer) }

      it 'returns forbidden' do
        post "/api/v1/bids/#{bid.id}/withdraw", headers: auth_headers(other_freelancer)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
