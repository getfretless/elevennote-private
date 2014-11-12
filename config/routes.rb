Rails.application.routes.draw do
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'
  root 'notes#index'
  resources :notes

  resources :users
  resources :sessions, only: [:new, :create, :destroy]

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :notes
    end
  end

end