require 'test_helper'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_user_and_log_in
    @url = 'https://www.google.com/image1.jpg'
  end

  test 'new image page' do
    get new_image_path

    assert_response :ok
    assert_select 'h1', 1, 'New Image URL'
    assert_select 'form#new_image[action=?]', images_path
  end

  test 'show page should display correct image' do
    image = Image.create!(url: @url, tag_list: 'tag', user_id: @user.id)
    get image_path(image)

    assert_response :ok
    assert_select '.js-image-card-container img[src=?]', image.url, 1
  end

  test 'show page should display image tags' do
    tags = %w(tag1 tag2 tag3)
    image = Image.create!(url: @url, tag_list: tags.join(', '), user_id: @user.id)
    get image_path(image)

    assert_select 'span.image-card__tag', 3 do |spans|
      spans.each_with_index do |span, i|
        assert_equal tags[i], span.text
      end
    end
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
               url: @url,
               tag_list: 'tag',
               user_id: @user.id
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
               tag_list: 'tag1, tag2, tag3',
               user_id: @user.id
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
               url: 'invalid',
               tag_list: 'tag',
               user_id: @user.id
             }
           }
    end

    assert_response :unprocessable_entity
    assert_select 'form#new_image[action=?]', images_path
    assert_select '.text-help', 'must be a valid url'
  end

  test 'create fails with no tags provided' do
    assert_no_difference 'Image.count' do
      post images_path,
           params: {
             image: {
               url: @url,
               tag_list: '',
               user_id: @user.id
             }
           }
    end

    assert_response :unprocessable_entity
    assert_select 'form#new_image[action=?]', images_path
    assert_select '.text-help', 'must have at least one tag'
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

  test 'share image successfully' do
    image = Image.create!(url: 'https://example.com', tag_list: 'tag', user_id: @user.id)
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post share_image_path(image),
           xhr: true,
           params: {
             share_form: {
               email_address: 'example@example.com',
               message: 'Hi!'
             }
           }
    end
    assert_response :ok

    share_email = ActionMailer::Base.deliveries.last
    assert_equal 'Image Shared from Image-Sharer!', share_email.subject
    assert_equal 'example@example.com', share_email.to[0]

    ['Hello from Image Sharer!', image.url, 'Hi!'].each do |value|
      assert_match value, share_email.html_part.to_s
      assert_match value, share_email.text_part.to_s
    end
  end

  test 'sharing image with no email address fails' do
    image = Image.create!(url: 'https://example.com', tag_list: 'tag', user_id: @user.id)
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      post share_image_path(image),
           xhr: true,
           params: {
             share_form: {
               message: 'Hi!'
             }
           }
    end
    assert_response :unprocessable_entity

    response_form_html_string = Nokogiri::HTML.parse(response.parsed_body['share_form_html']).inner_html
    assert_match 'form', response_form_html_string
    assert_match "action=\"#{share_image_path(image)}\"", response_form_html_string
    assert_match "can't be blank", response_form_html_string
  end

  test 'share_send action invalid email error' do
    image = Image.create!(url: 'https://example.com', tag_list: 'tag', user_id: @user.id)
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      post share_image_path(image),
           xhr: true,
           params: {
             share_form: {
               email_address: 'invalid',
               message: 'Hi!'
             }
           }
    end
    assert_response :unprocessable_entity

    response_form_html_string = response.parsed_body['share_form_html']
    assert_match 'form', response_form_html_string
    assert_match "action=\"#{share_image_path(image)}\"", response_form_html_string
    assert_match 'is invalid', response_form_html_string
  end

  test 'share_send action image does not exist' do
    assert_difference 'ActionMailer::Base.deliveries.size', 0 do
      post share_image_path(-1),
           xhr: true,
           params: {
             share_form: {
               email_address: 'valid@valid.com',
               message: 'Hi!'
             }
           }
    end
    assert_response :not_found
    assert_equal 'The image you were looking for does not exist', flash[:danger]
  end

  test 'delete removes image successfully' do
    image = Image.create!(url: 'https://www.google.com/image2.png', tag_list: 'tag', user_id: @user.id)

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

  test 'edit displays correct form' do
    image = Image.create!(url: 'https://static.pexels.com/photos/7919/pexels-photo.jpg',
                          tag_list: 'stuff, cool', user_id: @user.id)
    get edit_image_path(image)

    assert_response :ok
    assert_select 'img', 1
    assert_select 'form[action=?]', "/images/#{image.id}"
    assert_select 'img[src=?]', 'https://static.pexels.com/photos/7919/pexels-photo.jpg'
    assert_select 'h1', 1, 'Edit Tags'
    assert_select 'input[value=?]', image.tag_list.to_s
  end

  test 'successful tag update should redirect to index and display flash message' do
    image = Image.create!(url: 'https://validurl.com', tag_list: 'stuff', user_id: @user.id)

    patch image_path(image), params: { image: { tag_list: 'neat, my_tag, other_tag' } }

    assert_redirected_to image_path
    assert_equal 'neat, my_tag, other_tag', image.reload.tag_list.to_s
    assert_equal 'Tags successfully updated', flash[:success]
  end

  test 'update tag list with no tags' do
    image = Image.create!(url: 'https://validurl.com', tag_list: 'stuff', user_id: @user.id)

    assert_no_difference 'image.tag_list.count' do
      patch image_path(image), params: { image: { tag_list: '' } }
    end

    assert_response :unprocessable_entity
    assert_select '.image_tag_list .text-help', 'must have at least one tag'
  end

  test 'submit form with nonexistent image' do
    patch image_path(-1), params: { image: { tag_list: 'neat, my_tag, other_tag' } }

    assert_redirected_to images_path
    assert_equal 'The image you were looking for does not exist', flash[:danger]
  end

  private

  def create_images
    Image.create!([{ url: @url, tag_list: 'tag4', user_id: @user.id },
                   { url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag3', user_id: @user.id,
                     created_at: Time.zone.now - 1.day },
                   { url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag2', user_id: @user.id,
                     created_at: Time.zone.now - 2.days },
                   { url: 'http://www.validurl.com/image.png', tag_list: 'tag1, tag2, tag3', user_id: @user.id,
                     created_at: Time.zone.now - 3.days }])
  end

  def create_user_and_log_in
    @user = User.create!(email: 'admin@email.com', password: 'password123')
    post sessions_path,
         params: {
           session: {
             email: @user.email,
             password: @user.password
           }
         }
  end
end
