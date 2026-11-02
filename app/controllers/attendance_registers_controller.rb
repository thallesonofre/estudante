# frozen_string_literal: true

class AttendanceRegistersController < ApplicationController
  before_action :require_teacher_or_director!
  before_action :load_subjects

  def index
    @selected_subject = if params[:subject_id].present?
      @subjects.find_by(id: params[:subject_id])
    else
      @subjects.first
    end

    @selected_date = params[:attended_on].present? ? Date.parse(params[:attended_on]) : Date.current
    @selected_bimester = (params[:bimester].presence || current_bimester_for(@selected_date)).to_i

    if @selected_subject
      @students = @selected_subject.classroom.students.ordered
      existing = Attendance.where(subject: @selected_subject, attended_on: @selected_date).index_by(&:student_id)
      @lesson_topic = existing.values.first&.lesson_topic
      @attendance_map = existing

      # Historical dates for this subject
      @recent_sessions = Attendance.where(subject: @selected_subject)
                                   .group(:attended_on, :bimester, :lesson_topic)
                                   .select("attended_on, bimester, lesson_topic, COUNT(*) as total_students, SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as absences_count")
                                   .order(attended_on: :desc)
                                   .limit(12)
    end
  end

  def create
    @selected_subject = @subjects.find(params[:subject_id])
    attended_on = Date.parse(params[:attended_on])
    bimester = params[:bimester].to_i
    lesson_topic = params[:lesson_topic].to_s.strip.presence || "Aula Regular"
    records = params[:attendances] || {}

    ActiveRecord::Base.transaction do
      records.each do |student_id, data|
        attendance = Attendance.find_or_initialize_by(
          student_id: student_id,
          subject_id: @selected_subject.id,
          attended_on: attended_on
        )
        attendance.bimester = bimester
        attendance.status = data[:status] || "present"
        attendance.lesson_topic = lesson_topic
        attendance.justification = data[:justification].presence
        attendance.save!
      end
    end

    redirect_to attendance_registers_path(subject_id: @selected_subject.id, attended_on: attended_on, bimester: bimester),
                notice: "Chamada do dia #{I18n.l(attended_on, default: attended_on.strftime('%d/%m/%Y'))} registrada com sucesso!"
  rescue StandardError => e
    redirect_to attendance_registers_path(subject_id: @selected_subject&.id, attended_on: params[:attended_on], bimester: params[:bimester]),
                alert: "Erro ao salvar chamada: #{e.message}"
  end

  private

  def load_subjects
    @subjects = accessible_subjects
  end

  def current_bimester_for(date)
    case date.month
    when 1..4 then 1
    when 5..7 then 2
    when 8..9 then 3
    else 4
    end
  end
end
