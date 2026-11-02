# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Role-Based Access and Admin Approval Flow", type: :request do
  before do
    Rails.application.load_seed
  end

  it "renders the public presentation landing page without exposing instant unapproved logins" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Estudante • Gestão Escolar")
    expect(response.body).to include("Quem transforma a gestão com o Sistema Estudante?")
    expect(response.body).to include("Teste o Nosso Sistema — Solicite seu Acesso")
    expect(response.body).not_to include("demo_login")
  end

  it "requires admin approval before a visitor who requested access can log in" do
    # 1. Visitor submits an access request on the landing page
    expect do
      post request_access_path, params: {
        institution_name: "Colégio Novo Saber",
        institution_type: "Colégio Privado (Fundamental / Médio)",
        contact_name: "Prof. Renato Alves",
        contact_email: "renato@novosaber.edu.br",
        phone: "(11) 98765-4321",
        requested_role: "teacher",
        message: "Quero testar o lançamento de notas"
      }
    end.to change(AccessRequest, :count).by(1)

    req = AccessRequest.last
    expect(req.status).to eq("pending")
    expect(User.find_by(email: "renato@novosaber.edu.br")).to be_nil

    # 2. Admin / Director logs in with credentials and approves the request
    post user_session_path, params: {
      user: { email: "diretor@estudante.edu.br", password: "password123" }
    }
    expect(response).to redirect_to(dashboard_path)

    patch approve_access_request_path(req), params: {
      role: "teacher",
      custom_password: "liberado123"
    }
    expect(response).to redirect_to(access_requests_path)

    req.reload
    expect(req.status).to eq("approved")
    expect(req.generated_password).to eq("liberado123")

    created_user = User.find_by(email: "renato@novosaber.edu.br")
    expect(created_user).to be_present
    expect(created_user.teacher?).to be(true)

    # 3. Admin signs out and the newly approved user signs in
    delete destroy_user_session_path
    post user_session_path, params: {
      user: { email: "renato@novosaber.edu.br", password: "liberado123" }
    }
    expect(response).to redirect_to(dashboard_path)
    follow_redirect!
    expect(response.body).to include("Central do Professor")
  end
end
