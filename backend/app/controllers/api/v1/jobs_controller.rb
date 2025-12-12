# frozen_string_literal: true

module Api
  module V1
    class JobsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_job, only: [:show, :update, :destroy]

      # GET /api/v1/jobs
      def index
        jobs = Job.includes(:client, :skills).active

        # Filter by skills
        if params[:skill].present?
          skill_names = Array(params[:skill])
          jobs = jobs.joins(:skills).where(skills: { slug: skill_names }).distinct
        end

        # Filter by budget
        if params[:budget_min].present?
          jobs = jobs.where('budget_min >= ?', params[:budget_min])
        end
        if params[:budget_max].present?
          jobs = jobs.where('budget_max <= ?', params[:budget_max])
        end

        # Filter by budget type
        if params[:budget_type].present?
          jobs = jobs.where(budget_type: params[:budget_type])
        end

        # Search by title or description
        if params[:q].present?
          jobs = jobs.where('title ILIKE ? OR description ILIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
        end

        jobs = jobs.order(created_at: :desc)
        paginated = paginate(jobs)

        render json: {
          jobs: paginated[:data].map { |j| job_response(j) },
          meta: paginated[:meta]
        }, status: :ok
      end

      # GET /api/v1/jobs/:id
      def show
        render json: { job: job_response(@job, detailed: true) }, status: :ok
      end

      # POST /api/v1/jobs
      def create
        unless current_user.can_post_jobs?
          return render json: { error: 'Only clients can post jobs' }, status: :forbidden
        end

        job = current_user.posted_jobs.build(job_params)
        
        # Add skills
        if params[:job][:skills].present?
          params[:job][:skills].each do |skill_name|
            skill = Skill.find_or_create_by(name: skill_name) do |s|
              s.slug = skill_name.parameterize
            end
            job.job_skills.build(skill: skill)
          end
        end

        if job.save
          render json: { job: job_response(job) }, status: :created
        else
          render json: { errors: job.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/jobs/:id
      def update
        authorize @job

        if @job.update(job_params)
          render json: { job: job_response(@job) }, status: :ok
        else
          render json: { errors: @job.errors }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/jobs/:id
      def destroy
        authorize @job

        if @job.bids.any?
          return render json: { error: 'Cannot delete job with existing bids' }, status: :unprocessable_entity
        end

        @job.destroy
        render json: { message: 'Job deleted successfully' }, status: :ok
      end

      private

      def set_job
        @job = Job.includes(:client, :skills, :bids).find(params[:id])
      end

      def job_params
        params.require(:job).permit(:title, :description, :budget_min, :budget_max, :budget_type, :deadline)
      end

      def job_response(job, detailed: false)
        response = {
          id: job.id,
          title: job.title,
          description: detailed ? job.description : job.description.truncate(200),
          budget_min: job.budget_min,
          budget_max: job.budget_max,
          budget_type: job.budget_type,
          skills: job.skills.pluck(:name),
          deadline: job.deadline,
          status: job.status,
          client: {
            id: job.client.id,
            name: job.client.name,
            avatar_url: job.client.avatar_url
          },
          bids_count: job.bids.count,
          created_at: job.created_at
        }

        if detailed && current_user&.id == job.client_id
          response[:bids] = job.bids.includes(:freelancer).map { |b| bid_response(b) }
        end

        response
      end

      def bid_response(bid)
        {
          id: bid.id,
          amount: bid.amount,
          cover_letter: bid.cover_letter.truncate(200),
          estimated_days: bid.estimated_days,
          status: bid.status,
          freelancer: {
            id: bid.freelancer.id,
            name: bid.freelancer.name,
            avatar_url: bid.freelancer.avatar_url,
            rating_cache: bid.freelancer.rating_cache
          },
          created_at: bid.created_at
        }
      end
    end
  end
end
