require_dependency "bloak/application_controller"

module Bloak
  class PostsController < ApplicationController
    before_action :set_post, only: [:show]

    # GET /posts
    def index
      @featured_posts = Post.published.featured.limit(3).order(published_at: :desc)
      @tags = Post.published.distinct.pluck(:topic).sort
      @active_tag = 'all'

      @pagy, @posts = pagy(Post.published.order(published_at: :desc), items: 12)
    end

    def topic
      @featured_posts = Post.published.featured.limit(3).order(published_at: :desc)
      @active_tag = params[:topic]
      @tags = Post.published.distinct.pluck(:topic).sort

      @pagy, @posts = pagy(Post.published.tagged(@active_tag).order(published_at: :desc), items: 12)
      render(:index)
    end

    def author
      @featured_posts = Post.published.featured.limit(3).order(published_at: :desc)
      @active_author = params[:name]
      @tags = Post.published.distinct.pluck(:topic).sort
      @active_tag = 'all'

      @pagy, @posts = pagy(Post.published.authored_by(@active_author).order(published_at: :desc), items: 12)
      render(:index)
    end

    def search
      @query = params[:query]

      @featured_posts = []
      @pagy, @posts = pagy(Post.published.search_by_content(@query).order(published_at: :desc), items: 12)
      @tags = Post.published.distinct.pluck(:topic).sort
      @active_tag = ''
    end

    # GET /posts/1
    def show
      @tags = Post.published.distinct.pluck(:topic).sort
      @active_tag = @post.topic
    end

    private

      # Use callbacks to share common setup or constraints between actions.
      def set_post
        @post = Post.friendly.find(params[:id])
      end
  end
end
