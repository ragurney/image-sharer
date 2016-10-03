require 'test_helper'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @url = 'https://www.google.com/image1.jpg'
  end

  test 'new image page' do
    get new_image_path

    assert_response :ok
    assert_select 'h1', 1, 'New Image URL'
    assert_select 'form#new_image[action=?]', images_path
  end

  test 'show page should display correct image' do
    image = Image.create!(url: @url)
    get image_path(image)

    assert_response :ok
    assert_select '.js-image-card-container img[src=?]', image.url, 1
  end

  test 'show page should display image tags' do
    tags = %w(tag1 tag2 tag3)
    image = Image.create!(url: @url, tag_list: tags.join(', '))
    get image_path(image)

    assert_select 'span.image-card__tag', 3 do |spans|
      spans.each_with_index do |span, i|
        assert_equal tags[i], span.text
      end
    end
  end

  test 'image show page has share button' do
    image = Image.create!(url: 'http://validurl.com', tag_list: 'some, awesome, tags')

    get image_path(image)

    assert_response :ok
    assert_select '.js-share-image[href=?]', share_new_image_path(image)
  end

  test 'show page should redirect with error for nonexistent image' do
    get image_path(id: -1)

    assert_redirected_to images_path
    assert_equal 'The image you were looking for does not exist', flash[:danger]
  end

  test 'create image successfully' do
    assert_difference 'Image.count' do
      post images_path,
           params: {
             image: {
               url: @url
             }
           }
    end

    assert_redirected_to image_path(Image.last)
    assert_equal 'Url successfully saved!', flash[:success]
  end

  test 'create image with tags successfully' do
    assert_difference 'Image.count' do
      post images_path,
           params: {
             image: {
               url: @url,
               tag_list: 'tag1, tag2, tag3'
             }
           }
    end

    assert_redirected_to image_path(Image.last)
  end

  test 'create fails with invalid url' do
    assert_no_difference 'Image.count' do
      post images_path,
           params: {
             image: {
               url: 'invalid'
             }
           }
    end

    assert_response :unprocessable_entity
    assert_select 'form#new_image[action=?]', images_path
    assert_select '.text-help', 'must be a valid url'
  end

  test 'image index with no selected tag' do
    get images_path

    assert_response :ok
    assert_select '.js-image-card-container img', Image.all.length
  end

  test 'image index with tag selected' do
    create_images

    get images_path tag: 'tag3'
    assert_response :ok

    assert_select 'span[text()="tag3"]', 2
    assert_select '.js-image-card-container img', 2
  end

  test 'image index with no images in db' do
    get images_path

    assert_response :ok
    assert_select '.js-image-card-container img', 0
    assert_select 'h1', 1, 'Images Homepage'
  end

  test 'images on index page are ordered by descending creating time' do
    urls = create_images.map(&:url)

    get images_path

    assert_response :ok
    assert_select '.js-image-card-container img', 4
    assert_select '.js-image-card-container img', class: /image-card__figure/ do |images|
      images.each_with_index do |_img, i|
        assert_select '[src=?]', urls[i]
      end
    end
  end

  test 'image cards have delete button and correct link' do
    images = create_images.map(&:id)

    get images_path

    assert_response :ok
    assert_select '.js-delete-image', 4 do |links|
      links.each_with_index do |link, index|
        assert_equal image_path(images[index]), link[:href]
      end
    end
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

  test 'share new for nonexistent image displays correct flash message and redirects' do
    get share_new_image_path(-1)
    assert_redirected_to images_path
    assert_equal 'The image you were looking for does not exist', flash[:danger]
  end

  test 'share image successfully' do
    image = Image.create!(url: 'https://example.com')
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post share_send_image_path(image),
           params: {
             share_form: {
               email_address: 'example@example.com',
               message: 'Hi!'
             }
           }
    end
    assert_redirected_to root_path
    assert_equal 'Email successfully sent!', flash[:success]

    share_email = ActionMailer::Base.deliveries.last
    assert_equal 'Image Shared from Image-Sharer!', share_email.subject
    assert_equal 'example@example.com', share_email.to[0]

    ['Hello from Image Sharer!', image.url, 'Hi!'].each do |value|
      assert_match value, share_email.html_part.to_s
      assert_match value, share_email.text_part.to_s
    end
  end

  test 'sharing image with no email address fails' do
    image = Image.create!(url: 'https://example.com')
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      post share_send_image_path(image),
           params: {
             share_form: {
               message: 'Hi!'
             }
           }
    end
    assert_response :unprocessable_entity
    assert_select 'form[action=?]', share_send_image_path(image)
    assert_select '.text-help', "can't be blank"
  end

  test 'share_send action invalid email error' do
    image = Image.create!(url: 'https://example.com')
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      post share_send_image_path(image),
           params: {
             share_form: {
               email_address: 'invalid',
               message: 'Hi!'
             }
           }
    end
    assert_response :unprocessable_entity
    assert_select 'form[action=?]', share_send_image_path(image)
    assert_select '.text-help', 'is invalid'
  end

  test 'share_send action image does not exist' do
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      post share_send_image_path(-1),
           params: {
             share_form: {
               email_address: 'valid@valid.com',
               message: 'Hi!'
             }
           }
    end
    assert_redirected_to images_path
    assert_equal 'The image you were looking for does not exist', flash[:danger]
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
    delete image_path(-1)
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
