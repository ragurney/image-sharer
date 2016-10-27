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

  test 'delete authorization error -> login -> redirect to show path' do
    image = Image.create!(url: 'https://valid.com/stuff.png', tag_list: 'tag', user_id: @user.id)

    delete image_path(image)

    assert_redirected_to new_session_path
    assert_equal 'You must log in before accessing that page!', flash[:danger]

    log_in_as(
      email: @user.email,
      password: @user.password
    )

    assert_redirected_to image_path(image)
    assert_equal 'That action could not be completed, please try again.', flash[:danger]
  end

  test 'all delete buttons are hidden if user is not logged in' do
    Image.create!([
      { url: 'https://valid.com/stuff.png', tag_list: 'tag', user_id: @user.id },
      { url: 'https://valid.com/stuff1.png', tag_list: 'tag1', user_id: @user.id },
      { url: 'https://valid.com/stuff2.png', tag_list: 'tag2', user_id: @user.id }
    ])

    get images_path

    assert_select 'a.js-delete-image', 0
  end

  test 'delete buttons only shown on images that belong to logged in user' do
    user2 = User.create!(email: 'valid1@email.com', password: 'password123')
    images = Image.create!([
      { url: 'https://valid.com/stuff.png', tag_list: 'tag', user_id: @user.id },
      { url: 'https://valid.com/stuff1.png', tag_list: 'tag1', user_id: user2.id },
      { url: 'https://valid.com/stuff2.png', tag_list: 'tag2', user_id: user2.id }
    ])

    log_in_as(email: @user.email, password: @user.password)

    get images_path

    assert_select 'a.js-delete-image', count: 1, text: 'Delete', href: "/images/#{images[0]}"
  end

  test 'edit authorization error -> login -> redirect to edit page' do
    image = Image.create!(url: 'https://valid.com/stuff.png', tag_list: 'tag', user_id: @user.id)

    get edit_image_path(image)

    assert_redirected_to new_session_path
    assert_equal 'You must log in before accessing that page!', flash[:danger]

    log_in_as(
      email: @user.email,
      password: @user.password
    )

    assert_redirected_to edit_image_path(image)
    assert_equal 'Successfully signed in!', flash[:success]
  end

  test 'update authorization error -> login -> redirect to show path' do
    image = Image.create!(url: 'https://valid.com/stuff.png', tag_list: 'tag', user_id: @user.id)

    patch image_path(image), params: { image: { tag_list: 'other_tag' } }

    assert_redirected_to new_session_path
    assert_equal 'You must log in before accessing that page!', flash[:danger]

    log_in_as(
      email: @user.email,
      password: @user.password
    )

    assert_redirected_to image_path(image)
    assert_equal 'That action could not be completed, please try again.', flash[:danger]
  end

  test 'all edit_tags buttons are hidden if user is not logged in' do
    Image.create!([
      { url: 'https://valid.com/stuff.png', tag_list: 'tag', user_id: @user.id },
      { url: 'https://valid.com/stuff1.png', tag_list: 'tag1', user_id: @user.id },
      { url: 'https://valid.com/stuff2.png', tag_list: 'tag2', user_id: @user.id }
    ])

    get images_path

    assert_select 'a.js-edit-image-tags', 0
  end

  test 'edit_tags buttons only shown on images that belong to logged in user' do
    user2 = User.create!(email: 'valid1@email.com', password: 'password123')
    images = Image.create!([
      { url: 'https://valid.com/stuff.png', tag_list: 'tag', user_id: @user.id },
      { url: 'https://valid.com/stuff1.png', tag_list: 'tag1', user_id: user2.id },
      { url: 'https://valid.com/stuff2.png', tag_list: 'tag2', user_id: user2.id }
    ])

    log_in_as(email: @user.email, password: @user.password)

    get images_path

    assert_select 'a.js-edit-image-tags', count: 1, text: 'Edit Tags', href: "/images/#{images[0]}/edit"
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
