Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :onboarding do
    resource :cv_upload, only: %i[new create], path: "cv"
    resource :profile, only: %i[show update] do
      get :status, on: :collection
      get :skills, on: :collection
    end
  end

  namespace :admin do
    root "candidates#index"
    resources :candidates, only: %i[index show] do
      resource :cv, only: :show, controller: "candidate_cvs"
    end
  end

  root "onboarding/cv_uploads#new"
end
