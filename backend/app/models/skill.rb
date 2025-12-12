# frozen_string_literal: true

class Skill < ApplicationRecord
  has_many :user_skills, dependent: :destroy
  has_many :users, through: :user_skills

  has_many :job_skills, dependent: :destroy
  has_many :jobs, through: :job_skills

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  scope :popular, -> { joins(:user_skills).group(:id).order('COUNT(user_skills.id) DESC') }

  private

  def generate_slug
    self.slug ||= name&.parameterize
  end
end
