Rails.application.routes.draw do
  devise_for :users
  
  root "home#index"
  
  resources :stations, only: [:index, :show]
  resources :strollers, only: [:index, :show]
  resources :rides, only: [:index, :show, :new, :create] do
    member do
      patch :end_ride
    end
  end
  resources :map, only: [:index]
  resources :maintenances, only: [:index, :new, :create]
  resources :cleanings, only: [:index, :new, :create]
  
  # Admin routes
  get 'admin/dashboard', to: 'admin#dashboard'

  # API Routes
  namespace :api do
    namespace :v1 do
      resources :stations, only: [:index, :show]
      resources :strollers, only: [:index, :show] do
        collection do
          post :scan
        end
      end
      resources :rides, only: [:index, :show, :create] do
        member do
          patch :end_ride
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
