# frozen_string_literal: true

class StudentPortalController < ApplicationController
  before_action :resolve_target_student

  def report_card
    @classroom = @student.current_classroom
    @subjects = @student.enrolled_subjects
    @reports = @subjects.map do |subject|
      AcademicCalculatorService.new(student: @student, subject: subject).summary
    end

    avgs = @reports.filter_map { |r| r[:annual_average] }
    @overall_annual_average = avgs.any? ? (avgs.sum / avgs.size.to_f).round(2) : 0.0
    @total_absences = @reports.sum { |r| r[:absences_count] }
    @total_classes = @reports.sum { |r| r[:total_classes] }
    @overall_attendance_rate = if @total_classes.positive?
      (((@total_classes - @total_absences).to_f / @total_classes) * 100.0).round(1)
    else
      100.0
    end
  end

  def attendances
    @classroom = @student.current_classroom
    @subjects = @student.enrolled_subjects
    @selected_subject_id = params[:subject_id]

    scope = Attendance.where(student: @student).includes(subject: :teacher).ordered
    scope = scope.where(subject_id: @selected_subject_id) if @selected_subject_id.present?
    @attendances = scope

    @subject_attendance_summaries = @subjects.map do |subject|
      AcademicCalculatorService.new(student: @student, subject: subject).summary
    end
  end

  private

  def resolve_target_student
    if (current_user.director? || current_user.teacher? || current_user.staff?) && params[:student_id].present?
      @student = User.student.find(params[:student_id])
    elsif current_user.student?
      @student = current_user
    else
      @student = User.student.ordered.first
    end

    redirect_to root_path, alert: "Nenhum aluno selecionado." unless @student
  end
end
