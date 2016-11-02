class ImagesController < ApplicationController
  include Loginable
  before_action :find_image_or_redirect, only: [:show, :destroy, :edit, :update]
  before_action :find_image_or_head_not_found, only: :share
  before_action -> { save_previous_path(request) }, except: :share

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def index
    @image_list = ImageSelector.select params[:tag]
  end

  def new
    @image = Image.new
    authorize @image
  end

  def create
    @image = Image.new(image_params.merge(user: current_user))
    authorize @image
    if @image.save
      redirect_to image_path(@image), flash: { success: 'Url successfully saved!' }
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @image
  end

  def update
    authorize @image
    if @image.update(image_update_params)
      redirect_to image_path(@image), flash: { success: 'Tags successfully updated' }
    else
      render :edit, status: :unprocessable_entity
    end
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
    authorize @image
    @image.destroy
    redirect_to images_path, flash: { success: 'Image successfully deleted!' }
  end

  private

  def image_params
    params.require(:image).permit(:url, :tag_list)
  end

  def image_update_params
    params.require(:image).permit(:tag_list)
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

  def user_not_authorized
    redirect_to new_session_path, flash: { danger: 'You must log in before accessing that page!' }
  end
end
