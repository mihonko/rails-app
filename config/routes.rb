Rails.application.routes.draw do
  resources :products
  # devise_for :admins
  # devise_for :users
  devise_for :admins, controllers: {
    sessions:      'admins/sessions',
    passwords:     'admins/passwords',
    registrations: 'admins/registrations'
  }
  devise_scope :admin do
    get '/admins/sign_out' => 'admins/sessions#destroy'
  end
  devise_for :users, controllers: {
    sessions:      'users/sessions',
    passwords:     'users/passwords',
    registrations: 'users/registrations'
  }
  devise_scope :user do
    get '/users/sign_out' => 'users/sessions#destroy'
  end
  root 'top#index'

  get '/users', to: 'users/top#index'

  get '/cart' => 'carts#cart'
  post '/add_item' => 'carts#add_item'
  post '/update_item' => 'carts#update_item'
  post '/delete_item' => 'carts#delete_item'

  get '/order' => 'orders#order'
  post '/order_confirm' => 'orders#confirm'
  post '/order_complete' => 'orders#complete'

  get '/order_history_list' => 'orders#list'
  get 'order_history/:id', to: 'orders#history', as: :order_history

  get '/address_list' => 'addresses#list'
  get '/add_address' => 'addresses#form'
  post '/add_address' => 'addresses#add_address'
  post '/delete_address' => 'addresses#delete_address'

  get '/card_list' => 'cards#list'
  get '/add_card' => 'cards#form'
  post '/add_card' => 'cards#add_card'
  post '/delete_card' => 'cards#delete_card'

  resources :products do
    resource :favorites, only: [:create, :destroy]
  end

  get '/favorite_list' => 'favorites#list'

  # 管理画面
  get '/admins', to: 'admins/top#index'

  namespace :admins do
    resources :products do
      collection do
        get 'search'
      end
    end
    resources :users do
      collection do
        get 'search'
        get 'index'
        get 'show'
      end
    end
    resources :orders do
      collection do
        get 'search'
        get 'index'
        get 'show'
      end
    end
  end

  # 開発環境の場合メール確認ページ
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
