Rails.application.routes.draw do
  
  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  # 出社中の社員一覧を取得するためのルーティング
  get '/present_employees', to: 'attendances#present_employees', as: :present_employees
  get '/new_page', to: 'users#new_page'

 

  resources :users do
    collection { post :import_csv }
    member do
      get 'edit_basic_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      get 'attendances/download', to: 'attendances#download', as: :download_attendances
      patch 'attendances/update_one_month' # この行が追加対象です。
      get 'attendances_change'
      get 'approved_log'
      patch 'show_update'
      get 'approve_onemonth'
      get 'overtime_confirmation'
      get 'overtime_application'
      patch 'update_overtime_application'
      
    end
    resources :attendances, only: :update
  end
    
  resources :bases
  
  resources :notifications do
    collection do
      post :batch_update
      
    end
  end
end