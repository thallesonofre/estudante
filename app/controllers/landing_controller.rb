# frozen_string_literal: true

class LandingController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @stats = {
      students: User.student.count,
      teachers: User.teacher.count,
      classrooms: Classroom.count,
      subjects: Subject.count
    }
  end

  def request_access
    access_request = AccessRequest.new(
      institution_name: params[:institution_name],
      institution_type: params[:institution_type],
      contact_name: params[:contact_name],
      email: params[:contact_email],
      phone: params[:phone],
      requested_role: params[:requested_role].presence || :director,
      message: params[:message]
    )

    if access_request.save
      redirect_to new_user_session_path,
                  notice: "Solicitação de teste enviada com sucesso para #{access_request.institution_name}! Assim que o Administrador/Diretor aprovar seu pedido, seu acesso será liberado para login."
    else
      redirect_to root_path(anchor: "solicitar"),
                  alert: "Não foi possível enviar a solicitação: #{access_request.errors.full_messages.to_sentence}"
    end
  end
end
