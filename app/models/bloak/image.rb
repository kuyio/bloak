module Bloak
  class Image < ApplicationRecord
    # Search
    include PgSearch::Model
    pg_search_scope :search_by_name, against: %w(name alt)

    # Active Storage
    has_one_attached :image_file

    # Validations
    validates :name, presence: true
    validates :name, uniqueness: true
    validates :alt, presence: true
    validate :image_validation
    validate :correct_image_mime_type

    def image_url
      if image_file.attached?
        Rails.application.routes.url_helpers.rails_blob_url(image_file, disposition: "attachment", only_path: true)
      else
        "#"
      end
    end

    def image_variant_url(options = {})
      if image_file.attached?
        Rails.application.routes.url_helpers.rails_representation_url(
          image_file.variant(options).processed,
          only_path: true
        )
      else
        "#"
      end
    end

    private

    def image_validation
      errors[:image] << 'is required' unless image_file.attached?
    end

    def correct_image_mime_type
      return unless image_file.attached? && !image_file.content_type.in?(%w(image/jpeg image/png))

      errors.add(:image, 'must be an image')
    end
  end
end
