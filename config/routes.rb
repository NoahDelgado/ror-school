Rails.application.routes.draw do
  # Root path - this will check if user is authenticated
  root "home#index"

  # Devise routes for authentication
  devise_for :people, controllers: {
    sessions: "people/sessions",
    registrations: "people/registrations"
  }

  # Resources
  resources :sections
  resources :statuses
  resources :grades
  resources :examinations
  resources :courses do
    resources :examinations
  end
  resources :subjects
  resources :school_classes
  resources :moments
  resources :rooms
  resources :addresses

  # Student dashboard
  get "student_dashboard", to: "student_dashboard#index"

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
