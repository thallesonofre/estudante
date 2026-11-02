# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :classroom
  belongs_to :teacher, class_name: "User", inverse_of: :taught_subjects

  has_many :assessments, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :students, through: :classroom

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :workload_hours, presence: true, numericality: { greater_than: 0 }

  scope :ordered, -> { order(:name) }

  def display_name
    "#{name} (#{classroom.name})"
  end
end
