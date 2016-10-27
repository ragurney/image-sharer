require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'new user' do
    get new_user_path
    assert_response :ok

    assert_select 'h1', 'Sign up'
    assert_select 'form[class="simple_form new_user"]'
  end

  test 'create valid user' do
    assert_difference 'User.count' do
      post users_path(user: { email: 'valid@user.com', password: '12345678',
                              password_confirmation: '12345678' })
    end
    assert_redirected_to images_path
    assert_equal 'User successfully created!', flash[:success]
  end

  test 'create invalid user' do
    assert_difference 'User.count', 0 do
      post users_path(user: { email: '', password: '12345678' })
    end
    assert_response :unprocessable_entity
    assert_select '.user_email .text-help', 'is an invalid email address'
  end

  test 'should not allow access to sign up page once logged in' do
    login_valid_user

    get new_user_path
    assert_redirected_to root_path
    assert_equal 'Oops! You are already logged in!', flash[:danger]
  end

  test 'should not allow user to sign up once logged in' do
    login_valid_user

    post users_path(user: { email: 'valid@email.com', password: '123password' })
    assert_redirected_to root_path
    assert_equal 'Oops! You are already logged in!', flash[:danger]
  end

  private

  def login_valid_user
    user = User.create!(email: 'valid@email.com', password: 'password123')

    post sessions_path,
         params: {
           session: {
             email: user.email,
             password: user.password
           }
         }
  end
end
