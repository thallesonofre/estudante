# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "landing#index"
  post "solicitar_acesso", to: "landing#request_access", as: :request_access

  get "painel", to: "dashboard#index", as: :dashboard

  resources :access_requests, only: [ :index, :destroy ] do
    member do
      patch :approve
      patch :reject
    end
  end

  resources :users
  resources :classrooms do
    member do
      post :enroll_student
      delete :unenroll_student
    end
  end
  resources :subjects
  resources :announcements

  resources :attendance_registers, only: [ :index, :new, :create ]
  resources :gradebooks, only: [ :index ] do
    collection do
      post :create_assessment
      post :bulk_create
      patch :update_assessment
      delete :destroy_assessment
    end
  end

  get "boletim", to: "student_portal#report_card", as: :report_card
  get "frequencia", to: "student_portal#attendances", as: :student_attendances
end
