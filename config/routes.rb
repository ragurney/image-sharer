Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :images do
    member do
      get :share_new
      post :share
      post :like
    end
  end

  resources :users, only: [:new, :create]

  get    '/login',   to: 'sessions#new', as: :new_session
  post   '/login',   to: 'sessions#create', as: :sessions
  delete '/logout',  to: 'sessions#destroy', as: :session

  root 'images#index'
end
