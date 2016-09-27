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
    @share_form = ShareForm.new
  end

  def share_send
    @share_form = ShareForm.new(email_params)

    if @share_form.valid?
      ImageMailer.send_share_email(email_address: @share_form.email_address, message: @share_form.message,
                                   url: @image.url).deliver_now
      flash[:success] = 'Email successfully sent!'
      redirect_to root_path
    else
      render :share_new, status: :unprocessable_entity
    end
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
    params.require(:share_form).permit(:email_address, :message)
  end

  def set_image
    if (@image = Image.find_by(id: params[:id]))
      @image
    else
      flash[:danger] = 'The image you were looking for does not exist'
      redirect_to images_path
    end
  end
end
