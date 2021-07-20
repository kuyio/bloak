require_dependency "bloak/application_controller"

module Bloak
  class PostsController < ApplicationController
    before_action :set_post, only: [:show, :edit, :update, :destroy]

    # GET /posts
    def index
      @featured_posts = Post.published.featured.limit(3).order(published_at: :desc)
      @posts = Post.published.order(published_at: :desc)
      @tags = Post.published.distinct.pluck(:topic).sort
      @active_tag = 'all'
    end

    def topic
      @featured_posts = Post.published.featured.limit(3).order(published_at: :desc)
      @active_tag = params[:topic]
      @posts = Post.published.tagged(@active_tag).order(published_at: :desc)
      @tags = Post.published.distinct.pluck(:topic).sort

      render :index
    end

    def search
      @query = params[:query]

      @featured_posts = []
      @posts = Post.published.search_by_content(@query).order(published_at: :desc)
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
