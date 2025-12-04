Rails.application.routes.draw do
  
  root "pages#home"

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # Combined events routes - ONLY ONE resources :events block
  resources :events, only: [:index, :show, :new, :create] do
    resources :registrations, only: [:create, :destroy]
    resources :tickets, only: [:create]
  end

  post '/webhooks/stripe', to: 'webhooks#stripe'

  resources :event_requests, only: [:new, :create, :show]

  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
end