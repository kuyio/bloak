module Bloak
  module Admin
    class AdminController < ApplicationController
      layout 'bloak/admin'

      def index
        redirect_to admin_posts_path && return
      end
    end
  end
end
