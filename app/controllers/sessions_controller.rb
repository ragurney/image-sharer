class SessionsController < ApplicationController
  include Loginable

  before_action :redirect_on_authenticated, only: [:new, :create]

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(session_params)
    if @session.valid?
      authenticate_and_login
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    flash[:success] = 'Successfully logged out'
    redirect_to root_path
  end

  private

  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end

  def authenticate_and_login
    user = User.find_by(email: session_params[:email].downcase)
    if user && user.authenticate(@session.password)
      handle_user_login(user)
      set_flash_if_previous_action_not_get

      redirect_to(session[:previous_path] || root_path, flash: { success: 'Successfully signed in!' })
    else
      flash[:danger] = 'There was a problem with your username and/or password'
      render :new, status: :bad_request
    end
  end

  def handle_user_login(user)
    log_in(user)
    remember(user) if @session.remember_me == '1'
  end

  def set_flash_if_previous_action_not_get
    if session[:previous_request_was_get] == 'false'
      flash[:danger] = 'That action could not be completed, please try again.'
    end
  end

  def log_out
    forget
    session.delete(:user_id)
    @current_user = nil
  end

  def remember(user)
    cookies.permanent.signed[:user_id] = user.id
  end

  def forget
    cookies.delete(:user_id)
  end
end
