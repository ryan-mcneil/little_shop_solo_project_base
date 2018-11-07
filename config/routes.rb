Rails.application.routes.draw do
  root 'welcome#show'

  get '/login', to: 'session#new'
  post '/login', to: 'session#create'
  get '/logout', to: 'session#destroy'

  get '/register', to: 'users#new'
  post '/register', to: 'users#create'

  get '/profile', to: 'users#show'

  namespace :profile do
    get 'edit'
    get 'orders'
    resources :addresses, only: [:new, :create]
  end
  resources :addresses, only: [:edit, :update]


  get '/dashboard', to: 'dashboard#show'
  namespace :dashboard do
    resources :orders, only: [:index]
    resources :items, only: [:index]
  end

  resources :orders, only: [:index, :show, :create] do
    patch ':order_item_id/fulfill', to: 'order_items#update', as: 'item_fulfill'
  end
  resources :order_items, only: [:update]

  resources :items, only: [:index, :show], param: :slug

  resources :users, only: [:index, :new, :create, :edit, :show, :update], param: :slug do
    resources :orders, only: [:index, :update]
    # resources :addresses, only: [:new, :create, :update]
    patch 'enable', to: 'users#update'
    patch 'disable', to: 'users#update'
  end
  get '/users/:user_id/addresses', to: 'profile/addresses#index', as: :user_addresses
  get '/users/:user_id/addresses/new', to: 'profile/addresses#new', as: :new_user_address
  post '/users/:user_id/addresses', to: 'profile/addresses#create'


  resources :merchants, only: [:index, :update, :show], param: :slug do
    resources :orders, only: [:index]
    resources :items, only: [:index, :new, :edit, :create, :update], param: :slug do
      patch 'enable', to: 'items#update'
      patch 'disable', to: 'items#update'
    end
  end

  resources :carts, path: '/cart', only: [:index]
  delete '/cart', to: 'carts#empty'
  delete '/cart/:item_id', to: 'carts#remove'
  patch '/cart/:item_id', to: 'carts#update', as: 'cart_item_quantity'

  # custom error pages
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"
end
