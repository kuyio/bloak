# frozen_string_literal: true

module Bloak
  class Image < ApplicationRecord
    # Search
    include PgSearch::Model

    pg_search_scope :search_by_name, against: %w[name alt]

    # Active Storage
    has_one_attached :image_file

    # Validations
    validates :name, presence: true
    validates :name, uniqueness: true
    validates :alt, presence: true
    validate :image_validation
    validate :correct_image_mime_type
    validate :image_file_size

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
      errors.add(:image, 'is required') unless image_file.attached?
    end

    def correct_image_mime_type
      return unless image_file.attached?
      return if image_file.content_type.in?(%w[image/jpeg image/png]) &&
        image_file.filename.to_s.match?(/\.(jpe?g|png)\z/i)

      errors.add(:image, "must be a JPEG or PNG image")
    end

    def image_file_size
      return unless image_file.attached? && image_file.blob.byte_size > 10.megabytes

      errors.add(:image, "must be smaller than 10 MB")
    end
  end
end
