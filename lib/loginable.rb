module Loginable
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    user_id = session[:user_id] || cookies[:user_id]
    @current_user ||= User.find_by(id: user_id)
  end

  def logged_in?
    current_user.present?
  end

  def redirect_on_authenticated
    redirect_to root_path, flash: { danger: 'Oops! You are already logged in!' } if logged_in?
  end

  def save_previous_path(request)
    session[:previous_path] = request.path
    session[:previous_request_was_get] = request.get?.to_s
  end
end
