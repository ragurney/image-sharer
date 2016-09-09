require 'test_helper'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @url = 'https://www.google.com/image1.jpg'
  end

  test 'should get images from page' do
    get new_image_path

    assert_response :ok
    assert_select 'h1', 1, 'New Image URL'
  end

  test 'should show correct image' do
    image = Image.create!(url: @url)
    get image_path(image)

    assert_response :ok
    assert_select 'img', 1
  end

  test 'should show error for incorrect image' do
    get image_path(id: -1)

    assert_response :not_found
    assert_equal 'The image you were looking for was not found!', response.body
  end

  test 'controller should create and put correctly (just image)' do
    assert_difference 'Image.count' do
      post images_path(image: { url: @url, tag_list: nil })
    end

    assert_response :found
    assert_equal 'Url successfully saved!', flash[:success]
  end

  test 'controller should create and put correctly (image and tags)' do
    assert_difference 'Image.count' do
      post images_path(image: { url: @url, tag_list: 'tag1, tag2, tag3' })
    end

    assert_response :found
  end

  test 'should show image with tags upon create' do
    tags = %w(tag1 tag2 tag3)
    image = Image.create!(url: @url, tag_list: tags.join(', '))
    get image_path(image)

    assert_select 'span.image-tag', 3 do |spans|
      spans.each_with_index do |span, i|
        assert_equal tags[i], span.text
      end
    end
  end

  test 'invalid url does not create image' do
    assert_no_difference 'Image.count' do
      post images_path(image: { url: nil, tag_list: nil })
    end

    assert_response :unprocessable_entity
  end

  test 'image index with no selected tag' do
    get images_path

    assert_response :ok
    assert_select 'img', Image.all.length
  end

  test 'image index with tag selected' do
    create_images

    get images_path tag: 'tag3'
    assert_response :ok

    assert_select 'span[text()="tag3"]', 2
    assert_select '.card', 2
  end

  test 'no images in db' do
    get images_path

    assert_response :ok
    assert_select 'img', 0
    assert_select 'h1', 1, 'Images Homepage'
  end

  test 'images are ordered by descending creating time' do
    urls = create_images.map(&:url)

    get images_path

    assert_response :ok
    assert_select 'img', 4
    assert_select 'img', class: /image-tile/ do |images|
      images.each_with_index do |_img, i|
        assert_select '[src=?]', urls[i]
      end
    end
  end

  test 'delete removes image successfully' do
    image = Image.create!(url: 'https://www.google.com/image2.png')

    assert_difference 'Image.count', -1 do
      delete image_path(image)
    end
    assert_response :ok

    response_hash = JSON.parse(@response.body)
    assert_equal({ 'image_id' => image.id }, response_hash)
  end

  private

  def create_images
    Image.create!([{ url: @url, tag_list: nil },
                   { url: 'http://www.validurl.com/image.png', tag_list: 'tag1, tag2, tag3',
                     created_at: Time.zone.now - 3.days },
                   { url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag2',
                     created_at: Time.zone.now - 2.days },
                   { url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag3',
                     created_at: Time.zone.now - 1.day }])
  end
end
