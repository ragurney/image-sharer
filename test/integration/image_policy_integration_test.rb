require 'test_helper'

class ImagePolicyIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(email: 'valid@email.com', password: 'password123')
  end

  test 'new authorization error -> login -> back to new_image_page after login' do
    get new_image_path

    assert_redirected_to new_session_path
    assert_equal 'You must log in before accessing that page!', flash[:danger]

    log_in_as(
      email: @user.email,
      password: @user.password
    )

    assert_redirected_to new_image_path
    assert_equal 'Successfully signed in!', flash[:success]
  end

  test 'create authorization error -> login -> redirect and show flash message' do
    post images_path,
         params: {
           image: {
             url: 'https://valid.com',
             tag_list: 'tag1, tag2, tag3'
           }
         }

    assert_redirected_to new_session_path
    assert_equal 'You must log in before accessing that page!', flash[:danger]

    log_in_as(
      email: @user.email,
      password: @user.password
    )

    assert_redirected_to images_path
    assert_equal 'Successfully signed in!', flash[:success]
    assert_equal 'That action could not be completed, please try again.', flash[:danger]
  end

  test 'New Image link hidden if user is not logged in' do
    get new_image_path
    assert_select 'a', text: 'New Image', count: 0

    log_in_as(email: @user.email, password: @user.password)

    get new_image_path
    assert_select 'a', text: 'New Image', count: 2
  end

  private

  def log_in_as(email:, password:)
    post sessions_path,
         params: {
           session: {
             email: email,
             password: password
           }
         }
  end
end
