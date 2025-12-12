# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Jobs', type: :request do
  include_context 'authenticated user'

  describe 'GET /api/v1/jobs' do
    let!(:open_jobs) { create_list(:job, 3, status: :open) }
    let!(:closed_job) { create(:job, status: :closed) }

    it 'returns open jobs' do
      get '/api/v1/jobs'
      
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['jobs'].length).to eq(3)
    end

    it 'supports search by query' do
      job = create(:job, title: 'Build a Ruby on Rails API', status: :open)
      
      get '/api/v1/jobs', params: { q: 'Ruby' }
      
      body = JSON.parse(response.body)
      expect(body['jobs'].map { |j| j['id'] }).to include(job.id)
    end

    it 'supports filtering by budget_type' do
      fixed_job = create(:job, budget_type: :fixed, status: :open)
      hourly_job = create(:job, budget_type: :hourly, status: :open)
      
      get '/api/v1/jobs', params: { budget_type: 'fixed' }
      
      body = JSON.parse(response.body)
      job_ids = body['jobs'].map { |j| j['id'] }
      expect(job_ids).to include(fixed_job.id)
      expect(job_ids).not_to include(hourly_job.id)
    end

    it 'includes pagination metadata' do
      get '/api/v1/jobs'
      
      body = JSON.parse(response.body)
      expect(body['meta']).to include('current_page', 'per_page', 'total_pages', 'total_count')
    end
  end

  describe 'GET /api/v1/jobs/:id' do
    let(:job) { create(:job) }

    it 'returns job details' do
      get "/api/v1/jobs/#{job.id}"
      
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['job']['id']).to eq(job.id)
      expect(body['job']['title']).to eq(job.title)
    end

    it 'returns 404 for non-existent job' do
      get '/api/v1/jobs/99999'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/jobs' do
    let(:client) { create(:user, :client) }
    let(:valid_params) do
      {
        job: {
          title: 'Build a modern web application',
          description: 'We need a skilled developer to build a full-stack web application using modern technologies like React and Node.js.',
          budget_min: 5000,
          budget_max: 10000,
          budget_type: 'fixed',
          deadline: 30.days.from_now.to_date.to_s,
          skills: ['React', 'Node.js']
        }
      }
    end

    context 'as a client' do
      it 'creates a new job' do
        expect {
          post '/api/v1/jobs', params: valid_params, headers: auth_headers(client)
        }.to change(Job, :count).by(1)
        
        expect(response).to have_http_status(:created)
      end

      it 'returns the created job' do
        post '/api/v1/jobs', params: valid_params, headers: auth_headers(client)
        
        body = JSON.parse(response.body)
        expect(body['job']['title']).to eq('Build a modern web application')
      end
    end

    context 'as a freelancer' do
      let(:freelancer) { create(:user, :freelancer) }

      it 'returns forbidden' do
        post '/api/v1/jobs', params: valid_params, headers: auth_headers(freelancer)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'with invalid params' do
      it 'returns errors for missing title' do
        params = valid_params.deep_dup
        params[:job][:title] = ''
        
        post '/api/v1/jobs', params: params, headers: auth_headers(client)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /api/v1/jobs/:id' do
    let(:client) { create(:user, :client) }
    let(:job) { create(:job, client: client) }

    it 'updates the job' do
      patch "/api/v1/jobs/#{job.id}", 
        params: { job: { title: 'Updated job title for testing purposes' } },
        headers: auth_headers(client)
      
      expect(response).to have_http_status(:ok)
      expect(job.reload.title).to eq('Updated job title for testing purposes')
    end

    it 'returns forbidden for non-owner' do
      other_client = create(:user, :client)
      
      patch "/api/v1/jobs/#{job.id}",
        params: { job: { title: 'Hacked title' } },
        headers: auth_headers(other_client)
      
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /api/v1/jobs/:id' do
    let(:client) { create(:user, :client) }
    let(:job) { create(:job, client: client) }

    context 'without bids' do
      it 'deletes the job' do
        delete "/api/v1/jobs/#{job.id}", headers: auth_headers(client)
        
        expect(response).to have_http_status(:ok)
        expect(Job.find_by(id: job.id)).to be_nil
      end
    end

    context 'with bids' do
      before { create(:bid, job: job) }

      it 'returns error' do
        delete "/api/v1/jobs/#{job.id}", headers: auth_headers(client)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
