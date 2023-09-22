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


  # scope "/users" do
  #   resources :user_settings, only: [:save]
  # end

  namespace :users do
    resources :user_settings, only: [:update]
    resources :users
  end
  get "settings/profile/:username", to: "users/user_settings#profile", as: 'user_settings_profile'
  get "settings/account/:username", to: "users/user_settings#account", as: 'user_settings_account'
  get 'users_suggestions', to: 'users/users#suggestions', as: 'users_suggestions'

  resources :improvements
  resources :unit_usage_examples

  namespace :unit do
    resources :units do
      member do
        get :preview
        get :view
      end
    end
    resources :unit_versions, except: [:show]
  end
  get "/:username/methods/:id", to: "unit/unit_versions#show", as: 'unit_version'

  namespace :algorithm do
    resources :algorithms, except: [:show] do
      member do
        get :preview
        get :view
      end
    end
    resources :algorithm_versions, except: [:show]
    resources :control_structures
    resources :steps


    resources :substeps
  end
  get "/node_template", to: "algorithm/nodes#template", as: 'node_template'
  get "/:username/algorithms/:id", to: "algorithm/algorithm_versions#show", as: 'algorithm_version'

  namespace :article do
    resources :articles do
      member do
        get :preview
        get :dynamic_view
      end
    end
    resources :article_versions, except: [:show]
  end
  get "/:username/articles/:id", to: "article/article_versions#show", as: 'article_version'

  namespace :simple_class do
    resources :simple_classes, except: [:show] do
      member do
        get :preview
        get :tree_view
        get :tree_map
      end
    end
    resources :interface_groups
    resources :class_containers
    # resources :interface_members
    get 'interface_members/preview/:id', to: 'interface_members#preview', as: 'preview'
    resources :simple_class_attributes
  end
  get "/:username/classes/:id", to: "simple_class/simple_classes#show", as: 'simple_class'

  namespace :framework do
    resources :frameworks, except: [:show] do
      member do
        get :preview
      end
    end
  end
  get "/:username/framework/:id", to: "framework/frameworks#show", as: 'framework'

  resources :folders, except: [:show]
  get "/:username/folders/:id", to: "folders#show", as: 'target_folder'

  resources :repositories, except: [:show]
  get "/:username/repositories/:id", to: "repositories#show", as: 'target_repository'

  resources :technologies, only: [:index]

  # search routes
  post 'search', to: 'search#index', as: 'search'
  get 'search_technologies', to: 'search#technologies', as: 'search_technologies'
  get 'main_search_technologies', to: 'search#serp_page_technologies', as: 'main_search_technologies'

  # tags
  get 'tags_suggestions', to: 'tags#suggestions', as: 'tags_suggestions'

  # post 'search/suggestions', to: 'search#suggestions', as: 'search_suggestions'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "static_pages#main_page"

  # resources :dashboards
  # get 'dashboard', to: 'dashboards#show', as: 'dashboard'

  get "/dashboard/repositories", to: "dashboards#repositories"
  # should be last in list of all routes
  get "/:username(/:target_folder)", to: "dashboards#show", as: 'dashboard'




end
