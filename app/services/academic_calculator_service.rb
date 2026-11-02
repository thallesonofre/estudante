# frozen_string_literal: true

class AcademicCalculatorService
  PASSING_GRADE = 6.0
  MIN_ATTENDANCE_RATE = 75.0
  BIMESTERS = [ 1, 2, 3, 4 ].freeze

  def initialize(student:, subject:)
    @student = student
    @subject = subject
    @assessments = Assessment.where(student: student, subject: subject).ordered.to_a
    @attendances = Attendance.where(student: student, subject: subject).to_a
  end

  def bimester_assessments(bimester)
    @assessments.select { |a| a.bimester == bimester.to_i }
  end

  # Soma de pontos/notas por bimestre
  def bimester_points_sum(bimester)
    list = bimester_assessments(bimester)
    return 0.0 if list.empty?

    list.sum { |a| a.score.to_f }.round(2)
  end

  # Quantidade de avaliações no bimestre
  def bimester_assessments_count(bimester)
    bimester_assessments(bimester).size
  end

  # Média Bimestral = Soma dos pontos/notas do bimestre ÷ Quantidade de avaliações
  def bimester_average(bimester)
    count = bimester_assessments_count(bimester)
    return nil if count.zero?

    (bimester_points_sum(bimester) / count.to_f).round(2)
  end

  # Média Anual = (Média 1º Bim + Média 2º Bim + Média 3º Bim + Média 4º Bim) ÷ 4
  def annual_average
    b1 = bimester_average(1) || 0.0
    b2 = bimester_average(2) || 0.0
    b3 = bimester_average(3) || 0.0
    b4 = bimester_average(4) || 0.0

    return nil if @assessments.empty?

    ((b1 + b2 + b3 + b4) / 4.0).round(2)
  end

  # Média parcial considerando apenas os bimestres já avaliados (auxiliar gerencial)
  def partial_average
    evaluated = BIMESTERS.filter_map { |b| bimester_average(b) }
    return nil if evaluated.empty?

    (evaluated.sum / evaluated.size.to_f).round(2)
  end

  def total_classes
    @attendances.size
  end

  def absences_count
    @attendances.count(&:absent?)
  end

  def justified_count
    @attendances.count(&:justified?)
  end

  def present_count
    @attendances.count { |a| a.present? || a.late? || a.justified? }
  end

  def attendance_rate
    return 100.0 if total_classes.zero?

    ((present_count.to_f / total_classes) * 100.0).round(1)
  end

  def bimester_absences(bimester)
    @attendances.count { |a| a.bimester == bimester.to_i && a.absent? }
  end

  def all_bimesters_completed?
    BIMESTERS.all? { |b| bimester_assessments_count(b).positive? }
  end

  def academic_status
    return { label: "Reprovado por Falta", badge: "status-danger" } if attendance_rate < MIN_ATTENDANCE_RATE

    avg = annual_average
    return { label: "Sem Avaliações", badge: "status-neutral" } if avg.nil?

    if all_bimesters_completed?
      if avg >= PASSING_GRADE
        { label: "Aprovado", badge: "status-success" }
      elsif avg >= 4.0
        { label: "Recuperação Final", badge: "status-warning" }
      else
        { label: "Reprovado por Nota", badge: "status-danger" }
      end
    else
      p_avg = partial_average || 0.0
      if p_avg >= PASSING_GRADE
        { label: "Em Curso (Regular)", badge: "status-info" }
      else
        { label: "Atenção Pedagógica", badge: "status-warning" }
      end
    end
  end

  def summary
    {
      student: @student,
      subject: @subject,
      bimesters: BIMESTERS.index_with do |b|
        {
          assessments: bimester_assessments(b),
          sum: bimester_points_sum(b),
          count: bimester_assessments_count(b),
          average: bimester_average(b),
          absences: bimester_absences(b)
        }
      end,
      annual_average: annual_average,
      partial_average: partial_average,
      total_classes: total_classes,
      absences_count: absences_count,
      justified_count: justified_count,
      attendance_rate: attendance_rate,
      status: academic_status
    }
  end
end
