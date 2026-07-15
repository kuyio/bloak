# frozen_string_literal: true

module Bloak
  class ApplicationController < ActionController::Base
    include Pagy::Backend

    protect_from_forgery with: :exception
    before_action :set_default_url_options

    content_security_policy do |policy|
      policy.default_src :self
      policy.script_src  :self
      policy.style_src   :self, :unsafe_inline
      policy.img_src     :self, :data, "https://gravatar.com"
      policy.font_src    :self
      policy.connect_src :self
      policy.frame_src   :none
      policy.object_src  :none
    end

    private

    def set_default_url_options
      Rails.application.routes.default_url_options = {
        host: request.host_with_port,
        protocol: request.protocol
      }
    end
  end
end
