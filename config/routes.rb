Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :images do
    member do
      get :share_new
      post :share
    end
  end

  resources :users, only: [:new]
  root 'images#index'
end
