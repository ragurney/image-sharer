require 'test_helper'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @url = 'http://jstsolutions.net/wp-content/themes/realty/lib/images/key_img2.png'
    @image = Image.create(url: @url)
  end

  test 'should get images form page' do
    get new_image_path

    assert_response :ok
    assert_select 'h1', 1, 'New Image URL'
  end

  test 'should show correct image' do
    get image_path(@image)

    assert_response :ok
    assert_select 'img', 1
  end

  test 'should show error for incorrect image' do
    get image_path(id: -1)

    assert_response :not_found
    assert_equal 'The image you were looking for was not found!', response.body
  end

  test 'controller should create and put correctly' do
    post images_path(image: { url: @url })

    assert_response :found
    assert_not_nil Image.find_by(url: @url)
  end

  test 'invalid url does not create image' do
    post images_path(image: { url: nil })

    assert_response :unprocessable_entity
    assert_equal 'Url cannot be empty', flash[:error]
  end
end