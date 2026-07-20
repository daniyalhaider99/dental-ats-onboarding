Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :onboarding do
    resource :cv_upload, only: %i[new create], path: "cv"
  end

  root "onboarding/cv_uploads#new"
end
