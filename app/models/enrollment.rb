# frozen_string_literal: true

class Enrollment < ApplicationRecord
  belongs_to :student, class_name: "User", inverse_of: :enrollments
  belongs_to :classroom

  validates :student_id, uniqueness: { scope: :classroom_id, message: "já está matriculado nesta turma" }
  validates :enrolled_on, presence: true

  before_validation :set_default_enrolled_on, on: :create

  private

  def set_default_enrolled_on
    self.enrolled_on ||= Date.current
  end
end
