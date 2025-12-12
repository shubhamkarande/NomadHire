# frozen_string_literal: true

Rails.application.routes.draw do
  # Health check for load balancers
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Authentication
      scope :auth do
        post 'sign_up', to: 'auth#sign_up'
        post 'sign_in', to: 'auth#sign_in'
        delete 'sign_out', to: 'auth#sign_out'
        get 'me', to: 'auth#me'
      end

      # Users
      resources :users, only: [:show, :update] do
        post 'skills', to: 'users#add_skills', on: :member
        resources :reviews, only: [:index]
      end

      # Search
      get 'search/freelancers', to: 'users#search_freelancers'

      # Jobs
      resources :jobs do
        resources :bids, only: [:index, :create]
      end

      # Bids
      resources :bids, only: [:show] do
        member do
          post 'accept'
          post 'decline'
          post 'withdraw'
        end
      end

      # Contracts
      resources :contracts, only: [:index, :show] do
        resources :milestones, only: [:create]
        resources :reviews, only: [:create]
      end

      # Milestones
      resources :milestones, only: [:show] do
        member do
          post 'pay'
          post 'complete'
          post 'release'
        end
        resources :disputes, only: [:create]
      end

      # Disputes
      resources :disputes, only: [:index, :show] do
        post 'cancel', on: :member
      end

      # Conversations (Chat)
      resources :conversations, only: [:index, :create, :show] do
        member do
          get 'messages'
          post 'messages', to: 'conversations#send_message'
        end
      end

      # Notifications
      resources :notifications, only: [:index] do
        patch 'read', on: :member
      end
      post 'notifications/read_all', to: 'notifications#read_all'

      # Webhooks (payment providers)
      post 'webhooks/stripe', to: 'webhooks#stripe'
      post 'webhooks/razorpay', to: 'webhooks#razorpay'

      # Admin namespace
      namespace :admin do
        resources :users, only: [:index, :show, :update] do
          post 'ban', on: :member
        end
        get 'stats', to: 'users#stats'
        
        resources :jobs, only: [:index, :destroy] do
          patch 'close', on: :member
        end

        resources :disputes, only: [:index, :show, :update] do
          post 'resolve', on: :member
        end
      end
    end
  end

  # ActionCable mount point
  mount ActionCable.server => '/cable'
end

