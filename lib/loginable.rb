module Loginable
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def redirect_on_authenticated
    redirect_to root_path, flash: { danger: 'Oops! You are already logged in!' } if logged_in?
  end
end
