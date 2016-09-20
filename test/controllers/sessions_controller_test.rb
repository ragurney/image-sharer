require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get new and display form' do
    get new_session_path

    assert_response :ok
    assert_select 'h1', 'Log In'
    assert_select 'form#new_session', 1
  end
end
