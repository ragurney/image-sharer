require 'test_helper'

class LoginableTest < ActiveSupport::TestCase
  class LoginableTestController < ActionController::Base
    include Loginable
  end

  def setup
    @users = User.create!([{ email: 'valid@email.com', password: 'password123' },
                           { email: 'valid2@email.com', password: 'password123' }])
    @controller = LoginableTestController.new
    @controller.request = ActionController::TestRequest.create
  end

  test 'log_in assigns correct id in session and registers user as logged in' do
    @controller.log_in(@users[0])
    assert_equal @users[0].id, @controller.session[:user_id]
  end

  test 'current_user should return correct user if regular log in (no remember me) was called' do
    @controller.session[:user_id] = @users[1].id
    assert_equal @users[1], @controller.current_user
  end

  test 'current_user should return nil without any user in session or cookie' do
    assert_nil @controller.current_user
  end

  test 'logged_in? should return true if user did not select remember me' do
    @controller.session[:user_id] = @users[1].id
    assert @controller.logged_in?
  end

  test 'logged_in should return false with no info in cookies' do
    assert_not @controller.logged_in?
  end
end
