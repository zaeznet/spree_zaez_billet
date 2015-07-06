Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :billet_settings, only: [:show, :edit, :update]
    get 'billet_settings/clear_shipping', to: 'billet_settings#clear_shipping', as: :clear_shipping

    get  'billets/shipping',    to: 'billets#shipping',    as: :billets_shipping
    get  'billets/return',      to: 'billets#return',      as: :billets_return
    post 'billets/register',    to: 'billets#register',    as: :billets_register
    post 'billets/return_info', to: 'billets#return_info', as: :billets_return_info
  end

  resources :billets, only: [:show]
end
