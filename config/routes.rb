Rails.application.routes.draw do
  scope module: :operation do
    root 'dashboard#index'
    resources :tabs do
      collection do
        get :progressing
        get :cancelled
        get :finished
        get :droped
        post :member_set_up
        post :visitor_set_up
      end
    end
    resources :members do
      resources :memberships
      member do
        get :cancel_confirmation
        put :cancel
      end
    end
    resources :users do
      collection do
        get :initial
        get :async_uniqueness_validate
      end
    end
    resources :cards do
      resources :bay_prices do
        collection do
          get :bulk_new
          post :bulk_create
        end
      end
      member do
        get :async_show
      end
    end
    resources :product_categories do
      resources :products
    end
    resources :products
    resources :coaches
    resources :bays do
      collection do
        get :bulk_new
        post :bulk_create
      end
    end
    resources :roles
    resources :operators
    resources :changelogs
    resources :error
    get :dashboard, to: 'dashboard#index', as: :dashboard
    get :sign_in, to: 'sessions#new', as: :sign_in
    post :sign_in, to: 'sessions#create'
    get :sign_out, to: 'sessions#destroy', as: :sign_out
  end
  namespace :public do
    get :welcome, to: 'home#welcome', as: :welcome
    get :get, to: 'home#get', as: :get
  end
end
