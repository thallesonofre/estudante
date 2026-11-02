# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_director!
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @role_filter = params[:role]
    @query = params[:q].to_s.strip

    scope = User.ordered
    scope = scope.where(role: @role_filter) if @role_filter.present? && User.roles.key?(@role_filter)
    if @query.present?
      scope = scope.where("name ILIKE :q OR email ILIKE :q OR registration_number ILIKE :q", q: "%#{@query}%")
    end

    @users = scope
    @classrooms = Classroom.ordered
    @counts = {
      all: User.count,
      director: User.director.count,
      teacher: User.teacher.count,
      student: User.student.count,
      staff: User.staff.count
    }
  end

  def show
    if @user.student?
      redirect_to report_card_path(student_id: @user.id)
    end
  end

  def new
    @user = User.new(role: params[:role].presence || :student, active: true)
    @classrooms = Classroom.ordered
  end

  def create
    @user = User.new(user_params)
    @user.password = params[:user][:password].presence || "escola123"
    @classrooms = Classroom.ordered

    if @user.save
      sync_student_classroom(@user, params[:classroom_id])
      redirect_to users_path(role: @user.role), notice: "#{@user.role_label} #{@user.name} cadastrado(a) com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @classrooms = Classroom.ordered
  end

  def update
    @classrooms = Classroom.ordered
    attrs = user_params.to_h
    attrs.delete("password") if attrs["password"].blank?

    if @user.update(attrs)
      sync_student_classroom(@user, params[:classroom_id])
      redirect_to users_path(role: @user.role), notice: "Cadastro de #{@user.name} atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: "Você não pode remover seu próprio usuário."
      return
    end

    role = @user.role
    if @user.destroy
      redirect_to users_path(role: role), notice: "Usuário removido com sucesso."
    else
      redirect_to users_path(role: role), alert: @user.errors.full_messages.to_sentence
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :role, :registration_number, :phone, :department, :job_title, :active)
  end

  def sync_student_classroom(user, classroom_id)
    return unless user.student? && classroom_id.present?

    user.enrollments.destroy_all
    Enrollment.create!(student: user, classroom_id: classroom_id, enrolled_on: Date.current)
  end
end
