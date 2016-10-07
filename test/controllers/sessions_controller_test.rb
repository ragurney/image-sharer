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

  test 'successful log in with remember me selected' do
    user = User.create!(email: 'valid@email.com', password: 'password123')
    login_as(user, remember_as: 1)

    assert_equal 'Successfully signed in!', flash[:success]
    assert_not_nil cookies['user_id']
  end

  test 'log out successfully, redirect to index page and show proper success message' do
    user = User.create!(email: 'valid@email.com', password: 'password123')
    login_as(user)

    assert_equal user.id, session[:user_id]

    delete session_path

    assert_redirected_to root_path
    assert_nil session[:user_id]
    assert_equal 'Successfully logged out', flash[:success]
  end

  test 'log out after remember me log in deletes user id in cookie' do
    user = User.create!(email: 'valid@email.com', password: 'password123')
    login_as(user, remember_as: 1)
    assert_not_nil cookies['user_id']

    delete session_path
    assert_redirected_to root_path
    assert_equal 'Successfully logged out', flash[:success]
    assert_empty cookies['user_id']
  end

  test 'should not allow access to log in page once logged in' do
    user = User.create!(email: 'valid@email.com', password: 'password123')
    login_as(user)

    get new_session_path
    assert_redirected_to root_path
    assert_equal 'Oops! You are already logged in!', flash[:danger]
  end

  test 'should not allow users to log in once logged in' do
    user = User.create!(email: 'valid@email.com', password: 'password123')
    login_as(user)

    post sessions_path,
         params: {
           session: {
             email: 'valid@email.com',
             password: 'password123'
           }
         }
    assert_redirected_to root_path
    assert_equal 'Oops! You are already logged in!', flash[:danger]
  end

  private

  def login_as(user, remember_as: false)
    post sessions_path,
         params: {
           session: {
             email: user.email,
             password: user.password,
             remember_me: remember_as
           }
         }

    assert_redirected_to root_path
  end
end
