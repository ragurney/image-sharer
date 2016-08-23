require 'test_helper'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @url = 'https://www.google.com/image1'
    @image = Image.create(url: @url)
  end

  test 'should get images from page' do
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
    assert_equal 'Url cannot be empty and must point to an image!', flash[:error]
  end

  test 'image index should list all images in db' do
    get root_path
    assert_response :ok
    assert_select 'img', Image.all.length
  end

  test 'images are ordered by descending creating time' do
    @image2 = Image.create(url: 'https://www.google.com/image2', created_at: Time.zone.now - 3.days)
    @image3 = Image.create(url: 'https://www.google.com/image3', created_at: Time.zone.now - 5.days)

    urls = %w(https://www.google.com/image1 https://www.google.com/image2 https://www.google.com/image3)

    get root_path

    assert_select 'img', 3
    assert_select 'img' do |images|
      images.each_with_index do |_img, i|
        assert_select '[src=?]', urls[i]
      end
    end
  end
end
