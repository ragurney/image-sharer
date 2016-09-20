require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get new and display form' do
    get new_session_path

    assert_response :ok
    assert_select 'h1', 'Log In'
    assert_select 'form#new_session', 1
  end

  test 'should show inline errors when email field is blank' do
    post sessions_path,
         params: {
           session: {
             email: '',
             password: '[FILTERED]'
           }
         }

    assert_response :unprocessable_entity
    assert_select '.session_email .text-muted', text: "can't be blank"
  end

  test 'should re-render with flash error message if user is not found' do
    post sessions_path,
         params: {
           session: {
             email: 'stuff',
             password: '[FILTERED]'
           }
         }

    assert_response :bad_request
    assert_equal 'There was a problem with your username and/or password', flash[:danger]
    assert_select 'input.email[value=?]', 'stuff'
  end

  test 'should re-render with flash error message if password does not match user' do
    User.create!(email: 'valid@email.com', password: 'password123')
    post sessions_path,
         params: {
           session: {
             email: 'valid@email.com',
             password: 'invalid'
           }
         }

    assert_response :bad_request
    assert_equal 'There was a problem with your username and/or password', flash[:danger]
    assert_select 'input.email[value=?]', 'valid@email.com'
  end

  test 'should redirect to index upon successful login' do
    user = User.create!(email: 'valid@email.com', password: 'password123')
    login_as(user)

    assert_equal 'Successfully signed in!', flash[:success]
  end

  test 'should find correct user even with uppercase email and log in successfully' do
    User.create!(email: 'valid@email.com', password: 'password123')
    post sessions_path,
         params: {
           session: {
             email: 'ValID@email.com',
             password: 'password123'
           }
         }

    assert_redirected_to root_path
    assert_equal 'Successfully signed in!', flash[:success]
  end

  private

  def login_as(user)
    post sessions_path,
         params: {
           session: {
             email: user.email,
             password: user.password
           }
         }

    assert_redirected_to root_path
  end
end
