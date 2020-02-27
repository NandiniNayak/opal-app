Rails.application.routes.draw do
  resources :attendances
  resources :cards
  resources :profiles
  resources :courses
  root 'home#page'
  
  # request from canvas LTI
  post '/canvas', to: 'canvas#page'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
