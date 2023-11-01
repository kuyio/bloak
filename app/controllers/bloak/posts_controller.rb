require_dependency "bloak/application_controller"

module Bloak
  class PostsController < ApplicationController
    before_action :set_post, only: [:show]

    # GET /posts
    def index
      set_tags
      set_featured_posts
      @active_tag = 'all'

      @pagy, @posts = pagy(
        Post.published.order(published_at: :desc).with_attached_cover_image,
        items: Bloak.num_items
      )
    end

    def topic
      topic = params[:topic]
      set_tags

      # 404 if the topic given in params is not a valid tag for any of the published posts
      raise ActiveRecord::RecordNotFound.new("Invalid Topic") unless @tags.include?(topic)

      set_featured_posts
      @pagy, @posts = pagy(
        Post.published.tagged_with(topic).order(published_at: :desc).with_attached_cover_image,
        items: Bloak.num_items
      )
      @active_tag = topic

      render(:index)
    end

    def author
      author = params[:name]
      authors = Post.published.distinct.pluck(:author_name).sort

      # 404 if the author given in params is not a valid author_name for any of the published posts
      raise ActiveRecord::RecordNotFound.new("Invalid Author") unless authors.include?(author)

      set_featured_posts
      set_tags
      @active_tag = 'all'

      @pagy, @posts = pagy(
        Post.published.authored_by(author).order(published_at: :desc).with_attached_cover_image,
        items: Bloak.num_items
      )

      render(:index)
    end

    def search
      @query = params[:query]

      @pagy, @posts = pagy(
        Post.published.search_by_content(@query).order(published_at: :desc).with_attached_cover_image,
        items: Bloak.num_items
      )

      set_tags
      @featured_posts = []
      @active_tag = ''
    end

    # GET /posts/1
    def show
      set_tags
      @active_tag = @post.topic
    end

    private

      # Use callbacks to share common setup or constraints between actions.
      def set_post
        @post = Post.with_attached_cover_image.friendly.find(params[:id])
      end

      def set_featured_posts
        @featured_posts = Post.published
          .featured
          .with_attached_cover_image
          .limit(Bloak.num_featured_posts)
          .order(published_at: :desc)
      end

      def set_tags
        @tags = Post.published.distinct.pluck(:topic).sort
      end
  end
end
