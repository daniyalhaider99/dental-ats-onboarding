Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :onboarding do
    resource :cv_upload, only: %i[new create], path: "cv"
    resource :profile, only: %i[show update] do
      get :status, on: :collection
      get :skills, on: :collection
    end
  end

  root "onboarding/cv_uploads#new"
end
