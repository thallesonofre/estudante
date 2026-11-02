# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "automatically generates a registration number based on role" do
    u = User.create!(name: "Teste Aluno", email: "teste@estudante.edu.br", password: "password123", role: :student)
    expect(u.registration_number).to start_with("MAT-")
    expect(u.role_label).to eq("Aluno(a)")
  end
end
