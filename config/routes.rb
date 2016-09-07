Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :images, except: [:edit, :update] do
    member do
      get :share_new
    end
  end

  root 'images#index'
end
