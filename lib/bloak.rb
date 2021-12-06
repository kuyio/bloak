require "bloak/version"
require "bloak/engine"

module Bloak
  mattr_accessor(:site_name)
  mattr_accessor(:admin_user)
  mattr_accessor(:admin_password)

  self.site_name = "The Blog"

  def self.configure
    yield self
  end
end
