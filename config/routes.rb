Rails.application.routes.draw do

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
    resources :units
    resources :unit_versions
  end

  namespace :algorithm do
    resources :algorithms
    resources :algorithm_versions
    resources :control_structures
    resources :steps
    resources :substeps

  end

  namespace :article do
    resources :article_versions
    resources :articles
  end

  namespace :simple_object do
    resources :folders
    resources :simple_objects
  end


  # search routes
  post 'search', to: 'search#index', as: 'search'
  post 'search/suggestions', to: 'search#suggestions', as: 'search_suggestions'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "static_pages#main_page"
end
