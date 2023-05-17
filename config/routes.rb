Rails.application.routes.draw do

  # resources :container_members


  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  devise_scope :user do
    get 'edit_tos_agreement', to: 'users/registrations#edit_tos_agreement'
  end

  resources :improvements
  resources :unit_usage_examples

  namespace :unit do
    resources :units do
      member do
        get :preview
      end
    end
    resources :unit_versions
  end

  namespace :algorithm do
    resources :algorithms do
      member do
        get :preview
      end
    end
    resources :algorithm_versions
    resources :control_structures
    resources :steps
    resources :substeps

  end

  namespace :article do
    resources :articles do
      member do
        get :preview
      end
    end
    resources :article_versions
  end

  namespace :simple_class do
    resources :simple_classes do
      member do
        get :preview
      end
    end
    resources :interface_groups
    resources :class_containers
    # resources :interface_members
  end

  namespace :framework do
    resources :frameworks do
      member do
        get :preview
      end
    end
  end

  resources :folders



  # search routes
  post 'search', to: 'search#index', as: 'search'
  post 'search/suggestions', to: 'search#suggestions', as: 'search_suggestions'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "static_pages#main_page"
end
