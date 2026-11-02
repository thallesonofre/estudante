# frozen_string_literal: true

class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(_resource)
    dashboard_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :role, :phone, :department, :job_title ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :phone, :department, :job_title ])
  end

  def require_director!
    return if current_user&.director?

    redirect_to dashboard_path, alert: "Acesso restrito à Direção Escolar."
  end

  def require_teacher_or_director!
    return if current_user&.director? || current_user&.teacher?

    redirect_to dashboard_path, alert: "Acesso restrito a Professores e Direção."
  end

  def accessible_subjects
    if current_user.director?
      Subject.includes(:classroom, :teacher).order(:name)
    elsif current_user.teacher?
      current_user.taught_subjects.includes(:classroom, :teacher).order(:name)
    else
      current_user.enrolled_subjects
    end
  end
  helper_method :accessible_subjects
end
