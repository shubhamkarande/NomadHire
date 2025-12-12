# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < BaseController
      # GET /api/v1/notifications
      def index
        notifications = current_user.notifications
                          .order(created_at: :desc)
                          .limit(params[:limit] || 50)
                          .offset(params[:offset] || 0)

        render json: {
          notifications: notifications.map { |n| notification_response(n) },
          unread_count: current_user.notifications.unread.count
        }, status: :ok
      end

      # PATCH /api/v1/notifications/:id/read
      def read
        notification = current_user.notifications.find(params[:id])
        notification.mark_as_read!
        
        render json: { 
          notification: notification_response(notification) 
        }, status: :ok
      end

      # POST /api/v1/notifications/read_all
      def read_all
        Notification.mark_all_read_for(current_user)
        
        render json: { message: 'All notifications marked as read' }, status: :ok
      end

      private

      def notification_response(notification)
        {
          id: notification.id,
          kind: notification.kind,
          payload: notification.payload,
          read: notification.read,
          created_at: notification.created_at
        }
      end
    end
  end
end
