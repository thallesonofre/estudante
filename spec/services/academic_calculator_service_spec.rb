# frozen_string_literal: true

require "rails_helper"

RSpec.describe AcademicCalculatorService, type: :service do
  let(:director) { User.create!(name: "Diretor", email: "dir@test.com", password: "password123", role: :director) }
  let(:teacher)  { User.create!(name: "Prof. Ana", email: "prof@test.com", password: "password123", role: :teacher) }
  let(:student)  { User.create!(name: "Aluno João", email: "aluno@test.com", password: "password123", role: :student) }
  let(:classroom) { Classroom.create!(name: "3º Ano A", academic_year: 2026, shift: "Matutino", grade_level: "Ensino Médio") }
  let(:subject_record) { Subject.create!(name: "Matemática", code: "MAT-101", workload_hours: 80, classroom: classroom, teacher: teacher) }

  before do
    Enrollment.create!(student: student, classroom: classroom)
  end

  describe "Bimester and Annual Calculations" do
    it "calculates sum of points, bimester average, and annual average across 4 bimesters" do
      # 1º Bimestre: 7.0 + 9.0 = 16.0 / 2 = 8.0
      Assessment.create!(student: student, subject: subject_record, bimester: 1, title: "Prova 1", score: 7.0)
      Assessment.create!(student: student, subject: subject_record, bimester: 1, title: "Trabalho 1", score: 9.0)

      # 2º Bimestre: 6.0 + 8.0 = 14.0 / 2 = 7.0
      Assessment.create!(student: student, subject: subject_record, bimester: 2, title: "Prova 2", score: 6.0)
      Assessment.create!(student: student, subject: subject_record, bimester: 2, title: "Trabalho 2", score: 8.0)

      # 3º Bimestre: 9.0 / 1 = 9.0
      Assessment.create!(student: student, subject: subject_record, bimester: 3, title: "Prova 3", score: 9.0)

      # 4º Bimestre: 8.0 + 8.0 = 16.0 / 2 = 8.0
      Assessment.create!(student: student, subject: subject_record, bimester: 4, title: "Prova 4", score: 8.0)
      Assessment.create!(student: student, subject: subject_record, bimester: 4, title: "Simulado", score: 8.0)

      calc = described_class.new(student: student, subject: subject_record)

      expect(calc.bimester_points_sum(1)).to eq(16.0)
      expect(calc.bimester_average(1)).to eq(8.0)
      expect(calc.bimester_average(2)).to eq(7.0)
      expect(calc.bimester_average(3)).to eq(9.0)
      expect(calc.bimester_average(4)).to eq(8.0)

      # Média Anual = (8.0 + 7.0 + 9.0 + 8.0) / 4 = 8.0
      expect(calc.annual_average).to eq(8.0)
      expect(calc.academic_status[:label]).to eq("Aprovado")
    end

    it "calculates attendance rate and detects failure by absence" do
      3.times do |i|
        Attendance.create!(student: student, subject: subject_record, attended_on: Date.new(2026, 3, i + 1), bimester: 1, status: :absent)
      end
      Attendance.create!(student: student, subject: subject_record, attended_on: Date.new(2026, 3, 10), bimester: 1, status: :present)

      calc = described_class.new(student: student, subject: subject_record)
      expect(calc.absences_count).to eq(3)
      expect(calc.attendance_rate).to eq(25.0)
      expect(calc.academic_status[:label]).to eq("Reprovado por Falta")
    end
  end
end
