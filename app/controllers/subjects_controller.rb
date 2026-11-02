# frozen_string_literal: true

class SubjectsController < ApplicationController
  before_action :require_director!, except: [ :index ]

  def index
    @subjects = accessible_subjects
    @classrooms = Classroom.ordered
    @teachers = User.teacher.ordered
    @new_subject = Subject.new(workload_hours: 80)
  end

  def create
    @subject = Subject.new(subject_params)
    if @subject.save
      redirect_to subjects_path, notice: "Disciplina #{@subject.name} cadastrada com sucesso!"
    else
      redirect_to subjects_path, alert: @subject.errors.full_messages.to_sentence
    end
  end

  def destroy
    subject = Subject.find(params[:id])
    subject.destroy!
    redirect_to subjects_path, notice: "Disciplina removida com sucesso."
  end

  private

  def subject_params
    params.require(:subject).permit(:name, :code, :workload_hours, :classroom_id, :teacher_id)
  end
end
