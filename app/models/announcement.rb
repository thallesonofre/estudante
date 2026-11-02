# frozen_string_literal: true

class Announcement < ApplicationRecord
  belongs_to :author, class_name: "User", inverse_of: :announcements

  enum :priority, {
    normal: 0,
    important: 1,
    urgent: 2
  }, default: :normal

  enum :audience, {
    everyone: 0,
    teachers_only: 1,
    students_only: 2,
    staff_only: 3
  }, default: :everyone

  validates :title, presence: true
  validates :content, presence: true

  before_validation :set_published_at, on: :create

  scope :ordered, -> { order(pinned: :desc, published_at: :desc) }
  scope :visible_for, ->(user) {
    return ordered if user.director?

    allowed = [ audiences[:everyone] ]
    allowed << audiences[:teachers_only] if user.teacher?
    allowed << audiences[:students_only] if user.student?
    allowed << audiences[:staff_only] if user.staff?
    where(audience: allowed).ordered
  }

  def priority_label
    case priority
    when "urgent"    then "Urgente"
    when "important" then "Importante"
    else "Informativo"
    end
  end

  def audience_label
    case audience
    when "teachers_only" then "Corpo Docente"
    when "students_only" then "Alunos"
    when "staff_only"    then "Equipe / Funcionários"
    else "Toda a Comunidade Escolar"
    end
  end

  private

  def set_published_at
    self.published_at ||= Time.current
  end
end
