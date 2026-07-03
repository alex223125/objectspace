Rails.application.routes.draw do

  ##### API ROUTES
  namespace :api, defaults: { format: :json } do
    # resources :algorithm_versions, only: [] do
    #   resources :improvements, only: [:index, :create], controller: 'algorithm_improvements'
    # end
    resources :improvements, only: [:index, :create], controller: 'improvements'
    resources :algorithm_versions, only: [] do
      member do
        post :generate_passport
      end
    end
  end


  # namespace :api, defaults: { format: :json } do
  #
  # end


  ##### REGULAR ROUTES
  resources :simple_class_interfaces
  resources :logging_nodes
  resources :permissions
  resources :leaves
  resources :algorithm_trees


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

  # Simple technologies

  namespace :article do
    resources :articles do
      member do
        get :preview
        get :view
      end
    end
    resources :article_versions, except: [:show]
  end
  get "/:ownername/articles/:id", to: "article/article_versions#show", as: 'article_version'

  namespace :unit do
    resources :units do
      member do
        get :preview
        get :view
      end
    end
    resources :unit_versions, except: [:show] do
      resources :comments
    end
  end
  get "/:ownername/methods/:id", to: "unit/unit_versions#show", as: 'unit_version'

  namespace :algorithm do
    resources :algorithms, except: [:show] do
      member do
        get :preview
        get :view
      end

      # Wicked gem controller to make step by step
      # resource :simple_algorithm_version_creation,
      #          only: %i[update],
      #          controller: 'simple_algorithm_version_creation'
    end
    resources :algorithm_versions, except: [:show]
    resources :control_structures
    resources :steps, except: [:show]
  end
  get "/node_template", to: "algorithm/nodes#template", as: 'node_template'
  get "/:ownername/algorithms/:id", to: "algorithm/algorithm_versions#show", as: 'algorithm_version'
  get "/:ownername/algorithms/:algorithm_version_id/steps/:id", to: "algorithm/steps#show", as: 'algorithm_version_step'

  ### simple_algorithm_version_creation
  # FLAT OPTIONAL ROUTE: Parentheses () make target_repository and target_folder optional siblings
  get '/algorithm/simple_algorithm_version_creation/new(/:target_repository)(/:target_folder)',
      to: 'algorithm/simple_algorithm_version_creation#new',
      as: 'new_custom_simple_algorithm_version_creation'

  # Custom Wizard Route Matrix mapping step tokens strictly onto :wizard_id
  get '/algorithm/simple_algorithm_version_creation/:wizard_id',
      to: 'algorithm/simple_algorithm_version_creation#show',
      as: 'simple_algorithm_version_creation'

  put '/algorithm/simple_algorithm_version_creation/:wizard_id',
      to: 'algorithm/simple_algorithm_version_creation#update'
  ### simple_algorithm_version_creation

  namespace :cheat_sheet do
    resources :cheat_sheets, except: [:show] do
      member do
        get :preview
        get :view
      end
    end
    resources :cheat_sheet_versions, except: [:show]
  end
  get "/:ownername/cheat_sheets/:id", to: "cheat_sheet/cheat_sheet_versions#show", as: 'cheat_sheet_version'

  namespace :cheat_sheet_group do
    resources :cheat_sheet_groups, except: [:show] do
      member do
        get :preview
        get :view
      end
    end
    resources :cheat_sheet_group_versions, except: [:show]
  end
  get "/:ownername/cheat_sheet_groups/:id", to: "cheat_sheet_group/cheat_sheet_group_versions#show", as: 'cheat_sheet_group_version'

  # shared for Simple Technologies
  resources :improvements, except: [:show]
  get "/:technology_name/improvements/:id", to: "improvements#show", as: 'improvement_show'

  resources :usage_examples do
    collection do
      get :preview_index
    end
  end
  ################################

  namespace :simple_class do
    resources :simple_classes, except: [:show] do
      member do
        get :preview
        get :tree_view
        get :tree_map
      end
    end
    resources :simple_class_attributes, except: [:show]
  end

  namespace :shared_class_layer do
    resources :interface_groups, except: [:show]
    resources :class_containers, except: [:show]

    resources :interface_members, except: [:show]
    resources :container_members, except: [:show]
    get 'interface_members/preview/:id', to: 'interface_members#preview', as: 'preview'
  end

  get "/:ownername/classes/:id", to: "simple_class/simple_classes#show", as: 'simple_class'
  get "/:ownername/components/:id", to: "shared_class_layer/class_containers#show", as: 'class_container'
  get "/:ownername/actions_group/:id", to: "shared_class_layer/interface_groups#show", as: 'interface_group'

  get "/:ownername/actions_group_member/:id", to: "shared_class_layer/interface_members#show", as: 'interface_member'
  get "/:ownername/component_member/:id", to: "shared_class_layer/container_members#show", as: 'container_member'

  get "/:ownername/classes/:class_id/attribute/:id", to: "simple_class/simple_class_attributes#show", as: 'simple_class_attribute'

  namespace :framework do
    resources :frameworks, except: [:show] do
      member do
        get :preview
        get :tree_map
      end
    end

    resources :framework_folders, except: [:show]
    resources :framework_members, except: [:show] do
      collection do
        get :new_members
        post :create_members
      end
    end
  end
  get "/:ownername/framework/:id", to: "framework/frameworks#show", as: 'framework'
  get "/:ownername/framework_folders/:id", to: "framework/framework_folders#show", as: 'framework_folder'
  get "/:ownername/framework_members/:id", to: "framework/framework_members#show", as: 'framework_member'
  # get "/framework_member_template", to: "framework/framework_members#template", as: 'framework_member_template'
  get "/framework_folder_members_list", to: "framework/framework_members#framework_folder_members_list", as: 'framework_folder_members_list'


  resources :folders, except: [:show]
  get "/:ownername/folders/:id", to: "folders#show", as: 'target_folder'

  resources :repositories, except: [:show]
  get "/:ownername/repositories/:id", to: "repositories#show", as: 'target_repository'

  resources :reports_repositories, except: [:show]
  get "/:ownername/reports_repositories/:id", to: "reports_repositories#show", as: 'target_reports_repository'


  resources :technologies, only: [:index]

  resources :comments do
    resources :comments
    collection do
      get :list
    end
  end

  namespace :algorithm_reports do
    resources :algorithm_reports, except: [:show]
    namespace :algorithm_execution do
      get 'initial_place'
      # get 'next_step'
      # get 'previous_step'
      # post 'update_step_result'
      get 'edit/:logging_step_id', :action => 'edit'
      patch 'update/:logging_step_id', :action => 'update'
      get 'included_algorithm_reports_options_pick/:logging_step_id', :action => 'included_algorithm_reports_options_pick'
    end
  end
  get "/:ownername/algorithm_reports/:id", to: "algorithm_reports/algorithm_reports#show", as: 'algorithm_report'



  # search routes
  post 'search', to: 'search#index', as: 'search'
  get 'search_technologies', to: 'search#technologies', as: 'search_technologies'
  get 'search_reports', to: 'search#reports', as: 'search_reports'
  get 'folder_content', to: 'search#folder_content', as: 'folder_content'
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
  get "/dashboard/reports", to: "dashboards#reports"

  # should be last in list of all routes
  get "/:username(/:target_folder)", to: "dashboards#show", as: 'dashboard'
end
