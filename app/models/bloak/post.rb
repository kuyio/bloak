module Bloak
  class Post < ApplicationRecord
    # Search
    include PgSearch::Model
    pg_search_scope :search_by_content, against: %w[title content]

    # Slugs
    extend FriendlyId
    friendly_id :title, use: :slugged

    # ActiveStorage
    has_one_attached :cover_image

    # Scopes
    scope :featured, -> { where(featured: true) }
    scope :published, -> { where(published: true) }
    scope :unpublished, -> { where(published: false) }
    scope :tagged, ->(topic) { where(topic: topic) }

    # Validations
    validates :topic, presence: true
    validates :title, presence: true
    validates :summary, presence: true
    validates :content, presence: true
    # validate  :image_validation

    # Callbacks
    before_save :update_reading_time

    def render
      ::MarkdownRenderer.md_to_html(content)
    end

    def gravatar(size = 32)
      gravatar_id = Digest::MD5.hexdigest(author_email.downcase)
      "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
    end

    def cover_image_url
      if cover_image.attached?
        Rails.application.routes.url_helpers.rails_blob_url(cover_image, disposition: "attachment", only_path: true)
      else
        "#"
      end
    end

    def cover_image_variant_url(options = {})
      if cover_image.attached?
        Rails.application.routes.url_helpers.rails_representation_url(
          cover_image.variant(options).processed,
          only_path: true,
        )
      else
        "#"
      end
    end

    def update_reading_time(speed = 4.1)
      self.reading_time = Nlp.reading_time(content, speed)
    end

    private

    def image_validation
      errors[:cover_image] << 'is required' unless cover_image.attached?
    end
  end
end
