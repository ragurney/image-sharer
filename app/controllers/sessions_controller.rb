class SessionsController < ApplicationController
  include Loginable

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

  private

  def session_params
    params.require(:session).permit(:email, :password, :remember_me)
  end

  def authenticate_and_login
    user = User.find_by(email: session_params[:email].downcase)
    if user && user.authenticate(@session.password)
      log_in(user)
      redirect_to(root_path, flash: { success: 'Successfully signed in!' })
    else
      flash[:danger] = 'There was a problem with your username and/or password'
      render :new, status: :bad_request
    end
  end
end
