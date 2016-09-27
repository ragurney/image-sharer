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

    assert_redirected_to images_path
    assert_equal 'The image you were looking for does not exist', flash[:danger]
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

  test 'share new displays correct form' do
    image = Image.create!(url: 'https://static.pexels.com/photos/7919/pexels-photo.jpg')
    get share_new_image_path(image)

    assert_response :ok
    assert_select 'img', 1
    assert_select 'form[action=?]', share_send_image_path(image)
    assert_select 'img[src=?]', 'https://static.pexels.com/photos/7919/pexels-photo.jpg'
    assert_select 'h1', 1, 'Share Your Image'
  end

  test 'share new missing image displays correct flash message and redirects' do
    image = Image.create!(url: 'https://static.pexels.com/photos/7919/pexels-photo.jpg')
    image.destroy

    get share_new_image_path(image)
    assert_redirected_to images_path
    assert_equal 'The image you were looking for does not exist', flash[:danger]
  end

  test 'share_send action email' do
    image = Image.create!(url: 'https://example.com')
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post share_send_image_path(image, share_form: { email_address: 'example@example.com', message: 'Hi!' })
    end
    assert_response :found
    assert_equal 'Email successfully sent!', flash[:success]

    share_email = ActionMailer::Base.deliveries.last
    assert_equal 'Image Shared from Image-Sharer!', share_email.subject
    assert_equal 'example@example.com', share_email.to[0]

    ['Hello from Image Sharer!', image.url, 'Hi!'].each do |value|
      assert_match value, share_email.html_part.to_s
      assert_match value, share_email.text_part.to_s
    end
  end

  test 'share_send action no email error' do
    image = Image.create!(url: 'https://example.com')
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      post share_send_image_path(image, share_form: { email_address: nil, message: 'Hi!' })
    end
    assert_response :unprocessable_entity
  end

  test 'share_send action invalid email error' do
    image = Image.create!(url: 'https://example.com')
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      post share_send_image_path(image, share_form: { email_address: 'invalid', message: 'Hi!' })
    end
    assert_response :unprocessable_entity
  end

  test 'share_send action image does not exist' do
    image = Image.create!(url: 'https://example.com')
    image.destroy
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      post share_send_image_path(image, share_form: { email_address: 'valid@valid.com', message: 'Hi!' })
    end
    assert_redirected_to images_path
    assert_equal 'The image you were looking for does not exist', flash[:danger]
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

  test 'check images have delete button and correct link' do
    image_ids = create_images.map(&:id)

    get images_path

    assert_response :ok
    assert_select '.js-delete-image', 4 do |links|
      links.each_with_index do |link, index|
        assert_equal "/images/#{image_ids[index]}", link[:href]
      end
    end
  end

  test 'check images have share button and correct link' do
    image = Image.create!(url: 'http://validurl.com', tag_list: 'some, awesome, tags')

    get image_path(image)

    assert_response :ok
    assert_select '.js-share-image[href=?]', "/images/#{image.id}/share_new"
  end

  test 'delete removes image successfully' do
    image = Image.create!(url: 'https://www.google.com/image2.png')

    assert_difference 'Image.count', -1 do
      delete image_path(image)
    end
    assert_redirected_to images_path
    assert_equal 'Image successfully deleted!', flash[:success]
  end

  test 'delete nonexistent image redirects correctly' do
    image = Image.create!(url: 'https://static.pexels.com/photos/7919/pexels-photo.jpg')
    image.destroy

    delete image_path(image)
    assert_redirected_to images_path
    assert_equal 'The image you were looking for does not exist', flash[:danger]
  end

  private

  def create_images
    Image.create!([{ url: @url, tag_list: nil },
                   { url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag3',
                     created_at: Time.zone.now - 1.day },
                   { url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag2',
                     created_at: Time.zone.now - 2.days },
                   { url: 'http://www.validurl.com/image.png', tag_list: 'tag1, tag2, tag3',
                     created_at: Time.zone.now - 3.days }])
  end
end
