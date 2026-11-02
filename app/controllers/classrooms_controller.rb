# frozen_string_literal: true

class ClassroomsController < ApplicationController
  before_action :require_director!, except: [ :index, :show ]
  before_action :set_classroom, only: [ :show, :edit, :update, :destroy, :enroll_student, :unenroll_student ]

  def index
    @classrooms = Classroom.includes(:subjects, :students).ordered
    @new_classroom = Classroom.new(academic_year: 2026)
  end

  def show
    @subjects = @classroom.subjects.includes(:teacher).ordered
    @students = @classroom.students.ordered
    @available_students = User.student.where.not(id: @students.select(:id)).ordered
    @teachers = User.teacher.ordered
  end

  def create
    @classroom = Classroom.new(classroom_params)
    if @classroom.save
      redirect_to classroom_path(@classroom), notice: "Turma #{@classroom.name} criada com sucesso!"
    else
      redirect_to classrooms_path, alert: @classroom.errors.full_messages.to_sentence
    end
  end

  def edit; end

  def update
    if @classroom.update(classroom_params)
      redirect_to classroom_path(@classroom), notice: "Turma atualizada com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @classroom.destroy!
    redirect_to classrooms_path, notice: "Turma removida com sucesso!"
  end

  def enroll_student
    student = User.student.find(params[:student_id])
    Enrollment.find_or_create_by!(student: student, classroom: @classroom)
    redirect_to classroom_path(@classroom), notice: "#{student.name} matriculado(a) na turma #{@classroom.name}!"
  rescue StandardError => e
    redirect_to classroom_path(@classroom), alert: e.message
  end

  def unenroll_student
    enrollment = @classroom.enrollments.find_by!(student_id: params[:student_id])
    enrollment.destroy!
    redirect_to classroom_path(@classroom), notice: "Matrícula removida da turma."
  end

  private

  def set_classroom
    @classroom = Classroom.find(params[:id])
  end

  def classroom_params
    params.require(:classroom).permit(:name, :academic_year, :shift, :room_number, :grade_level)
  end
end
