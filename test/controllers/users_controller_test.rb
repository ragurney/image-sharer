require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'new user' do
    get new_user_path
    assert_response :ok

    assert_select 'h1', 'Sign up'
    assert_select 'form[class="simple_form new_user"]'
  end
end
