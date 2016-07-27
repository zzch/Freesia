Rails.application.routes.draw do
  mount API => '/'
  scope module: :operation do
    root 'dashboard#index'
    get :dashboard, to: 'dashboard#index', as: :dashboard
    resources :tabs do
      resources :line_items do
        collection do
          get :new_driving
          get :new_product
          get :new_course
          get :new_other
          post :create_driving
          post :create_product
          post :create_course
          post :create_other
        end
      end
      collection do
        get :progressing
        get :cancelled
        get :finished
        get :droped
        post :member_set_up
        post :visitor_set_up
      end
      member do
        get :checkout
        put :check
        get :trash_confirmation
        put :trash
        get :cancel_confirmation
        put :cancel
      end
    end
    resources :line_items do
      member do
        patch :async_update_quantity
        patch :async_update_started_at
        patch :async_update_ended_at
        patch :update_driving_pay_method
        patch :update_non_driving_pay_method
        delete :cancel
        put :finish
        get :edit_bay
        patch :update_bay
      end
    end
    resources :members do
      resources :memberships
      resources :member_transactions
      member do
        get :cancel_confirmation
        put :cancel
      end
    end
    resources :users do
      resources :members
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
      member do
        put :open
        put :close
      end
    end
    resources :roles
    resources :operators
    resources :changelogs
    resources :error
    get :sign_in, to: 'sessions#new', as: :sign_in
    post :sign_in, to: 'sessions#create'
    get :sign_out, to: 'sessions#destroy', as: :sign_out
  end
  scope as: :admin, module: :administration, path: :admin do
    root 'dashboard#index'
    get :dashboard, to: 'dashboard#index', as: :dashboard
    resources :clubs do
      resources :bays do
        collection do
          get :bulk_new_pairing
          post :bulk_create_pairing
        end
      end
    end
    resources :bays
    resources :machines
    get :sign_in, to: 'sessions#new', as: :sign_in
    post :sign_in, to: 'sessions#create'
    get :sign_out, to: 'sessions#destroy', as: :sign_out
  end
  namespace :public do
    get :welcome, to: 'home#welcome', as: :welcome
    get :get, to: 'home#get', as: :get
  end
end
