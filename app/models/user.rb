# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, {
    director: 0,
    teacher: 1,
    student: 2,
    staff: 3
  }, default: :student

  # Teacher associations
  has_many :taught_subjects, class_name: "Subject", foreign_key: :teacher_id, dependent: :restrict_with_error, inverse_of: :teacher

  # Student associations
  has_many :enrollments, foreign_key: :student_id, dependent: :destroy, inverse_of: :student
  has_many :classrooms, through: :enrollments
  has_many :assessments, foreign_key: :student_id, dependent: :destroy, inverse_of: :student
  has_many :attendances, foreign_key: :student_id, dependent: :destroy, inverse_of: :student

  # Announcements
  has_many :announcements, foreign_key: :author_id, dependent: :destroy, inverse_of: :author

  validates :name, presence: true
  validates :registration_number, presence: true, uniqueness: true

  before_validation :assign_registration_number, on: :create

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  def role_label
    case role
    when "director" then "Diretor(a)"
    when "teacher"  then "Professor(a)"
    when "student"  then "Aluno(a)"
    when "staff"    then "Funcionário(a)"
    else "Usuário"
    end
  end

  def role_badge_color
    case role
    when "director" then "badge-director"
    when "teacher"  then "badge-teacher"
    when "student"  then "badge-student"
    when "staff"    then "badge-staff"
    else "badge-secondary"
    end
  end

  def initials
    name.to_s.split.first(2).map { |w| w[0] }.join.upcase
  end

  def current_classroom
    classrooms.order(academic_year: :desc).first
  end

  def enrolled_subjects
    return Subject.none unless student?

    Subject.where(classroom_id: classrooms.select(:id)).includes(:classroom, :teacher).order(:name)
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : "Sua conta ainda não foi liberada ou está desativada pelo Administrador."
  end

  private

  def assign_registration_number
    return if registration_number.present?

    prefix = case role
    when "director" then "DIR"
    when "teacher"  then "PROF"
    when "staff"    then "FUNC"
    else "MAT"
    end
    self.registration_number = "#{prefix}-#{Time.current.year}#{SecureRandom.random_number(10_000..99_999)}"
  end
end
