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
end
