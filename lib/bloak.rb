require "bloak/version"
require "bloak/engine"
require "bloak/nlp"
require "bloak/markdown_renderer"
require "bloak/media"
require "friendly_id"

module Bloak
  self.mattr_accessor :site_name
  self.mattr_accessor :admin_user
  self.mattr_accessor :admin_password

  self.site_name = "The Blog"

  def self.configure
    yield self
  end
end
