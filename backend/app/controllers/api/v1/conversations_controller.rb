# frozen_string_literal: true

module Api
  module V1
    class ConversationsController < BaseController
      before_action :set_conversation, only: [:show, :messages]

      # GET /api/v1/conversations
      def index
        conversations = current_user.conversations
                          .includes(:participant_1, :participant_2, :messages)
                          .order(updated_at: :desc)

        render json: {
          conversations: conversations.map { |c| conversation_response(c) }
        }, status: :ok
      end

      # POST /api/v1/conversations
      def create
        recipient = User.find(params[:recipient_id])
        
        if recipient.id == current_user.id
          return render json: { error: 'Cannot start conversation with yourself' }, status: :unprocessable_entity
        end

        conversation = Conversation.between(current_user, recipient)
        
        render json: { conversation: conversation_response(conversation) }, status: :created
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Recipient not found' }, status: :not_found
      end

      # GET /api/v1/conversations/:id
      def show
        authorize_conversation_access!
        render json: { conversation: conversation_response(@conversation, detailed: true) }, status: :ok
      end

      # GET /api/v1/conversations/:id/messages
      def messages
        authorize_conversation_access!
        
        # Mark messages as read
        @conversation.mark_as_read_by!(current_user)
        
        messages = @conversation.messages
                      .includes(:sender)
                      .order(created_at: :desc)
                      .limit(params[:limit] || 50)
                      .offset(params[:offset] || 0)

        render json: {
          messages: messages.reverse.map { |m| message_response(m) }
        }, status: :ok
      end

      # POST /api/v1/conversations/:id/messages
      def send_message
        @conversation = Conversation.find(params[:id])
        authorize_conversation_access!

        message = @conversation.messages.build(
          sender: current_user,
          body: params[:body]
        )

        if message.save
          render json: { message: message_response(message) }, status: :created
        else
          render json: { errors: message.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_conversation
        @conversation = Conversation.find(params[:id])
      end

      def authorize_conversation_access!
        unless @conversation.participants.include?(current_user)
          render json: { error: 'Not authorized' }, status: :forbidden
        end
      end

      def conversation_response(conversation, detailed: false)
        other = conversation.other_participant(current_user)
        last_msg = conversation.last_message

        response = {
          id: conversation.id,
          other_participant: {
            id: other.id,
            name: other.name,
            avatar_url: other.avatar_url
          },
          unread_count: conversation.unread_count_for(current_user),
          last_message: last_msg ? {
            body: last_msg.body.truncate(50),
            sender_id: last_msg.sender_id,
            created_at: last_msg.created_at
          } : nil,
          updated_at: conversation.updated_at
        }

        response
      end

      def message_response(message)
        {
          id: message.id,
          body: message.body,
          sender_id: message.sender_id,
          sender_name: message.sender.name,
          read_at: message.read_at,
          created_at: message.created_at
        }
      end
    end
  end
end
