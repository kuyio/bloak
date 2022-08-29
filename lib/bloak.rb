require "bloak/version"
require "bloak/engine"

module Bloak
  mattr_accessor(:site_name)
  mattr_accessor(:copyright)

  mattr_accessor(:admin_user)
  mattr_accessor(:admin_password)

  self.site_name = "The Blog"
  self.copyright = "© 2022 #{Bloak.site_name} &mdash; All rights reserved.".html_safe

  def self.configure
    yield self
  end
end
