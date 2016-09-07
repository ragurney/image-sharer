class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :share_new, :share_send, :destroy]

  def index
    @image_list = ImageSelector.select params[:tag]
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(image_params)
    if @image.save
      flash[:success] = 'Url successfully saved!'
      redirect_to image_path(@image)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def share_new
  end

  def share_send
    email_info = email_params

    ImageMailer.send_share_email(email_info[:email_address], email_info[:message], @image.url).deliver_now
  rescue ArgumentError
    flash[:error] = 'Email cannot be null!'
    render :share_new, status: :unprocessable_entity
  else
    flash[:success] = 'Image successfully sent!'
    redirect_to root_path
  end

  def destroy
    @image.destroy
    flash[:success] = 'Image successfully deleted!'
    redirect_to images_path
  end

  private

  def image_params
    params.require(:image).permit(:url, :tag_list)
  end

  def email_params
    params.require(:email_info).permit(:email_address, :message)
  end

  def set_image
    if (@image = Image.find_by(id: params[:id]))
      @image
    else
      flash[:error] = 'The image you were looking for does not exist'
      redirect_to images_path
    end
  end
end
