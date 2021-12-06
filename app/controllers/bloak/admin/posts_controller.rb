require_dependency "bloak/application_controller"

module Bloak
  module Admin
    class PostsController < AdminController
      before_action :set_post, only: [:show, :edit, :update, :destroy, :toggle_featured, :toggle_published]

      # GET /posts
      def index
        @pagy, @posts = pagy(Post.order(published_at: :desc), items: 20)
      end

      # GET /posts/new
      def new
        @post = Post.new
      end

      # GET /posts/1
      def show
        stream = render_to_string(template: 'bloak/admin/posts/show')
        send_data(stream,
          filename: "#{@post.published_at.strftime('%Y-%m-%d')}-#{@post.slug}.md",
          type: "text/plain")
      end

      # GET /posts/1/edit
      def edit
      end

      # POST /posts
      def create
        @post = Post.new(post_params)

        if @post.save
          redirect_to(admin_posts_url, notice: 'Post was successfully created.')
        else
          render(:new)
        end
      end

      # PATCH/PUT /posts/1
      def update
        if @post.update(post_params)
          if params[:commit] == "Save and Close"
            redirect_to(admin_posts_url, notice: 'Post was successfully updated.')
          else
            flash.now[:success] = "Post saved."
            render(:edit)
          end
        else
          render(:edit)
        end
      end

      # DELETE /posts/1
      def destroy
        @post.destroy
        redirect_to(admin_posts_url, notice: 'Post was successfully destroyed.')
      end

      # Custom Actions

      def search
        @query = params[:query]
        if @query.present?
          @pagy, @posts = pagy(Post.search_by_content(@query).order(published_at: :desc), items: 20)
        else
          @pagy, @posts = pagy(Post.order(published_at: :desc), items: 20)
        end

        render(:index)
      end

      def toggle_featured
        @post.update(featured: !@post.featured)
        redirect_to(admin_posts_url)
      end

      def toggle_published
        @post.update(published: !@post.published)
        redirect_to(admin_posts_url)
      end

      private

        # Use callbacks to share common setup or constraints between actions.
        def set_post
          @post = Post.friendly.find(params[:id])
        end

        # Only allow a list of trusted parameters through.
        def post_params
          params.require(:post).permit(:cover_image, :title, :topic, :summary, :content, :author_name, :author_email,
:published, :featured, :reading_time, :published_at)
        end
    end
  end
end
