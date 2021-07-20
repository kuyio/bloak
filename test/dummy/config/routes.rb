Rails.application.routes.draw do
  mount Bloak::Engine => "/blog"
end
