Rails.application.routes.draw do

  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'


  get '/working_employee_list', to: 'users#working_employee_list'
  
  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_user_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      get 'attendances/fix_log'
      get 'attendances/show_changed_request'
      patch 'attendances/approve_changed_request'
      
      get 'attendances/show_apply_overtime'
      patch 'attendances/apply_overtime'
      get 'attendances/show_overtime_request'
      patch 'attendances/approve_overtime_request'
      patch 'attendances/apply_affiliation'
      get 'attendances/show_apply_affiliation'
      patch 'attendances/approve_affiliation'
    end
    collection { post :import }
    resources :attendances, only: :update
  end
  resources :bases
end