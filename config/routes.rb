Rails.application.routes.draw do
  
  root "pages#home"

  devise_for :users, controllers: {
  omniauth_callbacks: "users/omniauth_callbacks"
}


  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :events, only: [:index, :show, :new, :create] do
    resources :registrations, only: [:create, :destroy]
  end

  resources :events do
  resources :tickets, only: [:create]
  # or if you want all CRUD operations:
  # resources :tickets
end

  resources :event_requests, only: [:new, :create, :show]

  get "about", to: "pages#about"
  get "contact", to: "pages#contact"
end
 