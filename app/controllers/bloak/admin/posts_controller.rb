require_dependency "bloak/application_controller"

module Bloak
  module Admin
    class PostsController < AdminController
      before_action :set_post, only: [:show, :edit, :update, :destroy]

      # GET /posts
      def index
        @posts = Post.order(published_at: :desc)
      end

      def search
        @query = params[:query]
        if @query.present?
          @posts = Post.search_by_content(@query).order(published_at: :desc)
        else
          @posts = Post.order(published_at: :desc)
        end

        render :index
      end

      # GET /posts/new
      def new
        @post = Post.new
      end

      # GET /posts/1/edit
      def edit
      end

      # POST /posts
      def create
        @post = Post.new(post_params)

        if @post.save
          redirect_to admin_posts_url, notice: 'Post was successfully created.'
        else
          render :new
        end
      end

      # PATCH/PUT /posts/1
      def update
        if @post.update(post_params)
          redirect_to admin_posts_url, notice: 'Post was successfully updated.'
        else
          render :edit
        end
      end

      # DELETE /posts/1
      def destroy
        @post.destroy
        redirect_to admin_posts_url, notice: 'Post was successfully destroyed.'
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_post
          @post = Post.friendly.find(params[:id])
        end

        # Only allow a list of trusted parameters through.
        def post_params
          params.require(:post).permit(:cover_image, :title, :topic, :summary, :content, :author_name, :author_email, :published, :featured, :reading_time, :published_at)
        end
    end
  end
end
