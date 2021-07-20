module Bloak
  module Media
    def self.image(name)
      Image.find_by(name: name)
    end

    def self.image_file(name)
      Image.find_by(name: name)&.image_file
    end

    def self.image_url(name)
      Rails.application.routes.url_helpers.rails_blob_url(image_file(name), disposition: "attachment", only_path: true)
    end

    def self.image_variant_url(name, options = {})
      Rails.application.routes.url_helpers.rails_representation_url(
        image_file(name).variant(options).processed,
        only_path: true,
      )
    end

    def self.image_alt(name)
      Image.find_by(name: name)&.alt
    end
  end
end