# frozen_string_literal: true

Bloak::Engine.routes.draw do
  root 'posts#index'

  resources :posts, only: [:index, :show]
  get '/tag/:topic', to: 'posts#topic', as: 'topic'
  get '/author/:name', to: 'posts#author', as: 'author'
  post 'search', to: 'posts#search', as: 'search'

  namespace :admin do
    get '/', to: "admin#index", as: "admin"

    resources :posts do
      member do
        patch "/featured", to: "posts#toggle_featured", as: "toggle_featured"
        patch "/publish", to: "posts#toggle_published", as: "toggle_published"
      end
    end
    post 'posts/search', to: 'posts#search'

    resources :images
    post 'images/search', to: 'images#search'
  end
end
