# frozen_string_literal: true

class JobPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.can_post_jobs?
  end

  def update?
    user.admin? || record.client_id == user.id
  end

  def destroy?
    user.admin? || record.client_id == user.id
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(status: :open)
      end
    end
  end
end
