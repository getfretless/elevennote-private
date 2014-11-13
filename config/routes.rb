Rails.application.routes.draw do
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'
  root 'welcome#index'
  resources :notes

  resources :users
  resources :sessions, only: [:create]

  delete   'logout' => 'sessions#destroy', as: :logout
  get       'login' => 'sessions#new',     as: :login
  get     'sign_up' => 'users#new',        as: :sign_up

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :notes
    end
  end

end
