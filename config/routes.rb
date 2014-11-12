Rails.application.routes.draw do
  mount Bootsy::Engine => '/bootsy', as: 'bootsy'
  root 'notes#index'
  resources :notes

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :notes
    end
  end

end