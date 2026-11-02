# frozen_string_literal: true

class Attendance < ApplicationRecord
  belongs_to :student, class_name: "User", inverse_of: :attendances
  belongs_to :subject

  enum :status, {
    present: 0,
    absent: 1,
    justified: 2,
    late: 3
  }, default: :present

  validates :attended_on, presence: true
  validates :bimester, inclusion: { in: [ 1, 2, 3, 4 ] }
  validates :student_id, uniqueness: { scope: [ :subject_id, :attended_on ], message: "já possui chamada registrada nesta data e disciplina" }

  scope :ordered, -> { order(attended_on: :desc) }
  scope :absences, -> { where(status: :absent) }

  def status_label
    case status
    when "present"   then "Presente"
    when "absent"    then "Falta"
    when "justified" then "Falta Justificada"
    when "late"      then "Atraso"
    end
  end

  def status_badge_class
    case status
    when "present"   then "status-present"
    when "absent"    then "status-absent"
    when "justified" then "status-justified"
    when "late"      then "status-late"
    end
  end
end
