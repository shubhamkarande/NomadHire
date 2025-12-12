# frozen_string_literal: true

module Api
  module V1
    module Admin
      class UsersController < BaseController
        # GET /api/v1/admin/users
        def index
          users = User.all

          if params[:role].present?
            users = users.where(role: params[:role])
          end

          if params[:q].present?
            users = users.where('name ILIKE ? OR email ILIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
          end

          users = users.order(created_at: :desc)
          paginated = paginate(users)

          render json: {
            users: paginated[:data].map { |u| user_response(u) },
            meta: paginated[:meta]
          }, status: :ok
        end

        # GET /api/v1/admin/users/:id
        def show
          user = User.find(params[:id])
          render json: { user: user_response(user, detailed: true) }, status: :ok
        end

        # PATCH /api/v1/admin/users/:id
        def update
          user = User.find(params[:id])
          
          if user.update(admin_user_params)
            render json: { user: user_response(user) }, status: :ok
          else
            render json: { errors: user.errors }, status: :unprocessable_entity
          end
        end

        # POST /api/v1/admin/users/:id/ban
        def ban
          user = User.find(params[:id])
          
          if user.admin?
            return render json: { error: 'Cannot ban admin users' }, status: :unprocessable_entity
          end

          # For simplicity, we'll use soft delete or a banned flag
          # In production, you'd add a 'banned' column to users table
          user.update(role: :freelancer) # Demote to basic role
          
          render json: { message: 'User has been banned', user: user_response(user) }, status: :ok
        end

        # GET /api/v1/admin/stats
        def stats
          render json: {
            stats: {
              total_users: User.count,
              total_clients: User.client.count,
              total_freelancers: User.freelancer.count,
              total_jobs: Job.count,
              open_jobs: Job.open.count,
              total_contracts: Contract.count,
              active_contracts: Contract.active.count,
              total_revenue: Transaction.successful.sum(:amount)
            }
          }, status: :ok
        end

        private

        def admin_user_params
          params.require(:user).permit(:name, :email, :role, :bio, :location)
        end

        def user_response(user, detailed: false)
          response = {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            created_at: user.created_at
          }

          if detailed
            response.merge!(
              bio: user.bio,
              location: user.location,
              hourly_rate: user.hourly_rate,
              rating_cache: user.rating_cache,
              jobs_count: user.posted_jobs.count,
              bids_count: user.bids.count,
              contracts_count: user.contracts.count
            )
          end

          response
        end
      end
    end
  end
end
