module Bloak
  module Admin
    class AdminController < ApplicationController
      layout 'bloak/admin'

      http_basic_authenticate_with(
        name:     Bloak.admin_user,
        password: Bloak.admin_password
      )

      def index
        redirect_to(admin_posts_path)
      end
    end
  end
end
