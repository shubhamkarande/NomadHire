# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      skip_before_action :authenticate_user!, only: [:show, :search_freelancers]

      # GET /api/v1/users/:id
      def show
        user = User.find(params[:id])
        render json: { user: public_user_response(user) }, status: :ok
      end

      # PATCH /api/v1/users/:id
      def update
        authorize current_user, :update?

        if current_user.update(user_params)
          render json: { user: full_user_response(current_user) }, status: :ok
        else
          render json: { errors: current_user.errors }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/search/freelancers
      def search_freelancers
        freelancers = User.where(role: :freelancer)

        # Filter by skills
        if params[:skill].present?
          skill_names = Array(params[:skill])
          freelancers = freelancers.joins(:skills).where(skills: { slug: skill_names }).distinct
        end

        # Filter by hourly rate
        if params[:min_rate].present?
          freelancers = freelancers.where('hourly_rate >= ?', params[:min_rate])
        end
        if params[:max_rate].present?
          freelancers = freelancers.where('hourly_rate <= ?', params[:max_rate])
        end

        # Filter by location
        if params[:location].present?
          freelancers = freelancers.where('location ILIKE ?', "%#{params[:location]}%")
        end

        # Search by name or bio
        if params[:q].present?
          freelancers = freelancers.where('name ILIKE ? OR bio ILIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
        end

        freelancers = freelancers.order(rating_cache: :desc, created_at: :desc)
        paginated = paginate(freelancers)

        render json: {
          freelancers: paginated[:data].map { |f| public_user_response(f) },
          meta: paginated[:meta]
        }, status: :ok
      end

      # POST /api/v1/users/:id/skills
      def add_skills
        skill_names = params[:skills] || []
        
        skill_names.each do |skill_name|
          skill = Skill.find_or_create_by(name: skill_name) do |s|
            s.slug = skill_name.parameterize
          end
          current_user.user_skills.find_or_create_by(skill: skill)
        end

        render json: { 
          user: full_user_response(current_user),
          skills: current_user.skills.pluck(:name)
        }, status: :ok
      end

      private

      def user_params
        params.require(:user).permit(:name, :bio, :hourly_rate, :location, :avatar_url)
      end

      def public_user_response(user)
        {
          id: user.id,
          name: user.name,
          role: user.role,
          bio: user.bio,
          skills: user.skills.pluck(:name),
          hourly_rate: user.hourly_rate,
          location: user.location,
          avatar_url: user.avatar_url,
          rating_cache: user.rating_cache,
          created_at: user.created_at
        }
      end

      def full_user_response(user)
        public_user_response(user).merge(
          email: user.email
        )
      end
    end
  end
end
