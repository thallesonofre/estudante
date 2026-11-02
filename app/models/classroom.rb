# frozen_string_literal: true

class Classroom < ApplicationRecord
  has_many :subjects, dependent: :destroy
  has_many :teachers, -> { distinct }, through: :subjects, source: :teacher
  has_many :enrollments, dependent: :destroy
  has_many :students, -> { order(:name) }, through: :enrollments, source: :student

  validates :name, presence: true
  validates :academic_year, presence: true, numericality: { only_integer: true }
  validates :shift, presence: true
  validates :grade_level, presence: true

  scope :ordered, -> { order(academic_year: :desc, name: :asc) }

  def full_title
    "#{name} • #{grade_level} (#{shift})"
  end
end
