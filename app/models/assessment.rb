# frozen_string_literal: true

class Assessment < ApplicationRecord
  BIMESTERS = [ 1, 2, 3, 4 ].freeze
  CATEGORIES = [ "Prova Bimestral", "Trabalho Prático", "Simulado", "Participação / Atividades", "Seminário" ].freeze

  belongs_to :student, class_name: "User", inverse_of: :assessments
  belongs_to :subject

  validates :bimester, inclusion: { in: BIMESTERS }
  validates :title, presence: true
  validates :category, presence: true
  validates :score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :max_score, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10 }
  validates :evaluated_on, presence: true

  before_validation :set_defaults, on: :create

  scope :for_bimester, ->(bim) { where(bimester: bim) }
  scope :ordered, -> { order(bimester: :asc, evaluated_on: :asc, id: :asc) }

  private

  def set_defaults
    self.evaluated_on ||= Date.current
    self.max_score ||= 10.0
  end
end
