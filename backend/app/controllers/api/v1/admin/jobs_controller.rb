# frozen_string_literal: true

module Api
  module V1
    module Admin
      class JobsController < BaseController
        # GET /api/v1/admin/jobs
        def index
          jobs = Job.includes(:client, :skills)

          if params[:status].present?
            jobs = jobs.where(status: params[:status])
          end

          if params[:q].present?
            jobs = jobs.where('title ILIKE ?', "%#{params[:q]}%")
          end

          jobs = jobs.order(created_at: :desc)
          paginated = paginate(jobs)

          render json: {
            jobs: paginated[:data].map { |j| job_response(j) },
            meta: paginated[:meta]
          }, status: :ok
        end

        # DELETE /api/v1/admin/jobs/:id
        def destroy
          job = Job.find(params[:id])
          job.destroy
          
          render json: { message: 'Job deleted successfully' }, status: :ok
        end

        # PATCH /api/v1/admin/jobs/:id/close
        def close
          job = Job.find(params[:id])
          job.update(status: :closed)
          
          render json: { message: 'Job closed', job: job_response(job) }, status: :ok
        end

        private

        def job_response(job)
          {
            id: job.id,
            title: job.title,
            status: job.status,
            budget_min: job.budget_min,
            budget_max: job.budget_max,
            client: {
              id: job.client.id,
              name: job.client.name,
              email: job.client.email
            },
            bids_count: job.bids.count,
            created_at: job.created_at
          }
        end
      end
    end
  end
end
