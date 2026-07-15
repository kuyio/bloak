# frozen_string_literal: true

Rails.application.routes.draw do
  mount Bloak::Engine => "/blog"
end
