# frozen_string_literal: true

class AccessRequestsController < ApplicationController
  before_action :require_director!
  before_action :set_access_request, only: [ :approve, :reject, :destroy ]

  def index
    @status_filter = params[:status]
    scope = AccessRequest.includes(:reviewed_by, :provisioned_user).ordered
    scope = scope.where(status: @status_filter) if @status_filter.present? && AccessRequest.statuses.key?(@status_filter)
    @access_requests = scope

    @counts = {
      all: AccessRequest.count,
      pending: AccessRequest.pending.count,
      approved: AccessRequest.approved.count,
      rejected: AccessRequest.rejected.count
    }
  end

  def approve
    role = params[:role].presence || @access_request.requested_role
    temp_password = params[:custom_password].presence || "teste#{SecureRandom.random_number(1000..9999)}"

    ActiveRecord::Base.transaction do
      user = User.find_or_initialize_by(email: @access_request.email.downcase.strip)
      user.name = @access_request.contact_name
      user.role = role
      user.phone = @access_request.phone
      user.department = @access_request.institution_name
      user.job_title = "Acesso Liberado (#{@access_request.institution_type})"
      user.password = temp_password
      user.active = true
      user.save!

      if user.student? && user.enrollments.empty? && Classroom.any?
        Enrollment.create!(student: user, classroom: Classroom.ordered.first, enrolled_on: Date.current)
      end

      @access_request.update!(
        status: :approved,
        generated_password: temp_password,
        reviewed_by: current_user,
        reviewed_at: Time.current,
        provisioned_user: user
      )
    end

    redirect_to access_requests_path,
                notice: "Acesso liberado para #{@access_request.contact_name} (#{@access_request.email})! Senha gerada: #{temp_password}"
  rescue StandardError => e
    redirect_to access_requests_path, alert: "Erro ao aprovar solicitação: #{e.message}"
  end

  def reject
    @access_request.update!(
      status: :rejected,
      reviewed_by: current_user,
      reviewed_at: Time.current
    )
    redirect_to access_requests_path, notice: "Solicitação de #{@access_request.contact_name} foi recusada."
  end

  def destroy
    @access_request.destroy!
    redirect_to access_requests_path, notice: "Registro de solicitação removido."
  end

  private

  def set_access_request
    @access_request = AccessRequest.find(params[:id])
  end
end
