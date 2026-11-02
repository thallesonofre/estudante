# frozen_string_literal: true

class GradebooksController < ApplicationController
  before_action :require_teacher_or_director!
  before_action :load_subjects

  def index
    @selected_subject = if params[:subject_id].present?
      @subjects.find_by(id: params[:subject_id])
    else
      @subjects.first
    end

    @selected_bimester = (params[:bimester].presence || 1).to_i

    return unless @selected_subject

    @students = @selected_subject.classroom.students.ordered
    @student_reports = @students.map do |student|
      AcademicCalculatorService.new(student: student, subject: @selected_subject).summary
    end
  end

  def create_assessment
    subject = @subjects.find(params[:subject_id])
    assessment = Assessment.new(
      student_id: params[:student_id],
      subject: subject,
      bimester: params[:bimester],
      title: params[:title],
      category: params[:category].presence || "Prova Bimestral",
      score: params[:score],
      max_score: params[:max_score].presence || 10.0,
      evaluated_on: params[:evaluated_on].presence || Date.current,
      feedback: params[:feedback]
    )

    if assessment.save
      redirect_to gradebooks_path(subject_id: subject.id, bimester: assessment.bimester),
                  notice: "Nota lançada com sucesso para #{assessment.student.name}!"
    else
      redirect_to gradebooks_path(subject_id: subject.id, bimester: params[:bimester]),
                  alert: "Erro ao lançar nota: #{assessment.errors.full_messages.to_sentence}"
    end
  end

  def bulk_create
    subject = @subjects.find(params[:subject_id])
    bimester = params[:bimester].to_i
    title = params[:title].to_s.strip
    category = params[:category].presence || "Prova Bimestral"
    evaluated_on = params[:evaluated_on].presence || Date.current
    scores = params[:scores] || {}

    if title.blank?
      redirect_to gradebooks_path(subject_id: subject.id, bimester: bimester),
                  alert: "Informe o título da avaliação para lançamento em lote."
      return
    end

    created_count = 0
    ActiveRecord::Base.transaction do
      scores.each do |student_id, score_val|
        next if score_val.to_s.strip.blank?

        num_score = score_val.to_s.tr(",", ".").to_f
        Assessment.create!(
          student_id: student_id,
          subject: subject,
          bimester: bimester,
          title: title,
          category: category,
          score: num_score,
          max_score: 10.0,
          evaluated_on: evaluated_on
        )
        created_count += 1
      end
    end

    redirect_to gradebooks_path(subject_id: subject.id, bimester: bimester),
                notice: "#{created_count} nota(s) da avaliação '#{title}' lançada(s) no #{bimester}º Bimestre!"
  rescue StandardError => e
    redirect_to gradebooks_path(subject_id: subject.id, bimester: bimester),
                alert: "Erro ao lançar notas em lote: #{e.message}"
  end

  def update_assessment
    assessment = Assessment.find(params[:id])
    subject = @subjects.find(assessment.subject_id)

    if assessment.update(score: params[:score].to_s.tr(",", "."), title: params[:title])
      redirect_to gradebooks_path(subject_id: subject.id, bimester: assessment.bimester),
                  notice: "Avaliação atualizada com sucesso!"
    else
      redirect_to gradebooks_path(subject_id: subject.id, bimester: assessment.bimester),
                  alert: assessment.errors.full_messages.to_sentence
    end
  end

  def destroy_assessment
    assessment = Assessment.find(params[:id])
    subject = @subjects.find(assessment.subject_id)
    bimester = assessment.bimester
    assessment.destroy!

    redirect_to gradebooks_path(subject_id: subject.id, bimester: bimester),
                notice: "Avaliação removida e médias recalculadas!"
  end

  private

  def load_subjects
    @subjects = accessible_subjects
  end
end
