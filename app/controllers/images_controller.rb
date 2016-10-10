class ImagesController < ApplicationController
  before_action :find_image_or_redirect, only: [:show, :destroy, :edit]
  before_action :find_image_or_head_not_found, only: :share

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

  def edit
  end

  def show
  end

  def share
    @share_form = ShareForm.new(email_params)

    if @share_form.valid?
      respond_to_valid_share_form
    else
      respond_to_invalid_share_form
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

  def find_image_or_redirect
    find_image_or { redirect_to images_path }
  end

  def find_image_or_head_not_found
    find_image_or { head :not_found }
  end

  def find_image_or
    if (@image = Image.find_by(id: params[:id]))
      @image
    else
      flash[:danger] = 'The image you were looking for does not exist'
      yield
    end
  end

  def respond_to_valid_share_form
    ImageMailer.send_share_email(email_address: @share_form.email_address, message: @share_form.message,
                                 url: @image.url).deliver_now
    head :ok
  end

  def respond_to_invalid_share_form
    share_form_html = render_to_string(
      partial: 'images/share_form',
      object: @share_form,
      locals: { image: @image }
    )
    render json: { share_form_html: share_form_html }, status: :unprocessable_entity
  end
end
