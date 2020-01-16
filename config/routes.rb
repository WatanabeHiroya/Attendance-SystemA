Rails.application.routes.draw do
  get 'bases/show'

  root 'static_pages#top'
  get '/signup', to: 'users#new'

  # ログイン機能
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '/working_employee_list', to: 'users#working_employee_list'
  get '/bases', to: 'bases#show'
  get '/bases/:id/edit', to: 'bases#edit'
  delete '/bases/:id/delete', to: 'bases#destroy'

  
  resources :users do
    member do
      get 'edit_basic_info'
      patch 'update_user_info'
      patch 'update_basic_info'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
    end
    collection { post :import }
    resources :attendances, only: :update
  end
end