Rails.application.routes.draw do
  resources :data
  get 'health', to: 'health#index'
end
