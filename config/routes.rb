Rails.application.routes.draw do
  get 'event_requests/new'
  get 'event_requests/create'
  get 'event_requests/show'
  get 'event_requests/index'
  get 'events/index'
  get 'events/show'
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  get 'pages/home'
  devise_for :users
  root "pages#home"


  resources :events, only: [:index, :show] do
    resources :registrations, only: [:create, :destroy]
  end

  resources :event_requests, only: [:new, :create, :show]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
