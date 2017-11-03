Rails.application.routes.draw do
  root 'static_pages#home'
  get 'sessions/new'
  get '/home', to: 'static_pages#home'
  get '/help', to: 'static_pages#help'
  get '/signup', to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users
  match '/patient/:id' => 'users#update_patient', via: :post, as: 'patient'
  match '/doctor/:id' => 'users#update_doctor', via: :post, as: 'doctor'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
