require "bloak/version"
require "bloak/engine"

module Bloak
  self.mattr_accessor :site_name
  self.mattr_accessor :admin_user
  self.mattr_accessor :admin_password

  self.site_name = "The Blog"

  def self.configure
    yield self
  end
end
