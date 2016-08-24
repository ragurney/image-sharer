class ImagesController < ApplicationController
  def index
    @image_list = Image.order(created_at: :desc)
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      flash[:success] = 'Url successfully saved!'
      redirect_to image_path(id: @image.id)
    else
      flash[:error] = 'Url cannot be empty'
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @image = Image.find(params['id'])
  rescue ActiveRecord::RecordNotFound => _e
    render plain: 'The image you were looking for was not found!', status: :not_found
  end

  private

  def image_params
    params.require(:image).permit(:url)
  end
end
