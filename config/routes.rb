Rails.application.routes.draw do

  root "pages#home"

  # Letter Opener Web - View emails in development at /letter_opener
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  devise_for :users, controllers: {
    registrations: 'users/devise_registrations',
    confirmations: 'users/confirmations',
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :events, only: [:index, :show, :new, :create] do
    resources :registrations, only: [:create, :destroy]
    resources :tickets, only: [:create, :new]
  end
  
  resources :tickets, only: [:index, :show]

  post '/webhooks/stripe', to: 'webhooks#stripe'

  resources :event_requests, only: [:new, :create, :show]

  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
end