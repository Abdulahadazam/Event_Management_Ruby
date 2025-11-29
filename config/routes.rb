Rails.application.routes.draw do
  
  root "pages#home"

  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :events, only: [:index, :show, :new, :create] do
    resources :registrations, only: [:create, :destroy]
  end


  resources :event_requests, only: [:new, :create, :show]

  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
end
