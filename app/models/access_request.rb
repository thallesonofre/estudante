# frozen_string_literal: true

class AccessRequest < ApplicationRecord
  belongs_to :reviewed_by, class_name: "User", optional: true
  belongs_to :provisioned_user, class_name: "User", optional: true

  enum :requested_role, {
    director: 0,
    teacher: 1,
    student: 2,
    staff: 3
  }, prefix: :wants

  enum :status, {
    pending: 0,
    approved: 1,
    rejected: 2
  }, default: :pending

  validates :institution_name, presence: true
  validates :institution_type, presence: true
  validates :contact_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :ordered, -> { order(status: :asc, created_at: :desc) }

  def requested_role_label
    case requested_role
    when "director" then "Diretor(a) / Gestor"
    when "teacher"  then "Professor(a)"
    when "student"  then "Aluno(a)"
    when "staff"    then "Funcionário(a)"
    else "Avaliador"
    end
  end

  def status_label
    case status
    when "pending"  then "Aguardando Liberação do Admin"
    when "approved" then "Acesso Liberado"
    when "rejected" then "Recusado"
    end
  end

  def status_badge_class
    case status
    when "pending"  then "status-warning"
    when "approved" then "status-success"
    when "rejected" then "status-danger"
    end
  end
end
