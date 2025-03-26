Rails.application.routes.draw do
  # Root path - this will check if user is authenticated
  root "home#index"

  # Devise routes for authentication
  devise_for :people, controllers: {
    sessions: "people/sessions",
    registrations: "people/registrations"
  }

  # Resources
  resources :users
  resources :sections
  resources :statuses
  resources :grades
  resources :examinations do
    member do
      patch :update_grades
    end
  end
  resources :courses do
    resources :examinations
  end
  resources :subjects
  resources :school_classes do
    collection do
      get :management
    end
    member do
      get :manage_students
      post :update_students
    end
  end
  resources :moments
  resources :rooms
  resources :addresses

  # Student dashboard
  get "student_dashboard", to: "student_dashboard#index"

  # Teacher dashboard
  get "teacher_dashboard", to: "teacher_dashboard#index"

  # Dean dashboard
  resources :dean_dashboard, only: [ :index ] do
    collection do
      get :manage_courses
      get :manage_bulletins
      get :student_bulletin
    end
  end

  # Schedules
  resources :schedules, only: [ :index ]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  resources :students do
    resources :grades, only: [ :index ], controller: "grades", action: "student_grades"
  end

  resources :examinations do
    resources :grades, shallow: true
  end
end
