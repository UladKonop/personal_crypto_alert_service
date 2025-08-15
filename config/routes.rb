Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Web interface routes
  root 'home#index'
  resources :alerts
  resources :notification_channels

  # API routes
  namespace :api do
    namespace :v1 do
      resources :alerts
      resources :notification_channels
    end
  end
end
