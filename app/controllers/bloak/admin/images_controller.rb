require_dependency "bloak/application_controller"

module Bloak
  module Admin
    class ImagesController < AdminController
      before_action :set_image, only: [:show, :edit, :update, :destroy]

      # GET /images
      def index
        @pagy, @images = pagy(Image.order(created_at: :desc), items: 20)
      end

      def search
        @query = params[:query]
        if @query.present?
          @pagy, @images = pagy(Image.search_by_name(@query).order(created_at: :desc), items: 20)
        else
          @pagy, @images = pagy(Image.order(created_at: :desc), items: 20)
        end

        render(:index)
      end

      # GET /images/1
      def show
      end

      # GET /images/new
      def new
        @image = Image.new
      end

      # GET /images/1/edit
      def edit
      end

      # POST /images
      def create
        @image = Image.new(image_params)

        if @image.save
          redirect_to(admin_images_path, notice: 'Image was successfully created.')
        else
          render(:new)
        end
      end

      # PATCH/PUT /images/1
      def update
        if @image.update(image_params)
          redirect_to(admin_images_path, notice: 'Image was successfully updated.')
        else
          render(:edit)
        end
      end

      # DELETE /images/1
      def destroy
        @image.destroy
        redirect_to(images_url, notice: 'Image was successfully destroyed.')
      end

      private

        # Use callbacks to share common setup or constraints between actions.
        def set_image
          @image = Image.find(params[:id])
        end

        # Only allow a list of trusted parameters through.
        def image_params
          params.require(:image).permit(:name, :alt, :image_file)
        end
    end
  end
end
