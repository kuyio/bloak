Bloak::Engine.routes.draw do
  root 'posts#index'

  resources :posts, only: [:index, :show]
  get '/tag/:topic', to: 'posts#topic', as: 'topic'
  post 'search', to: 'posts#search', as: 'search'

  namespace :admin do
    get '/', to: "admin#index", as: "admin"

    resources :posts
    post 'posts/search', to: 'posts#search'

    resources :images
    post 'images/search', to: 'images#search'
  end
end
