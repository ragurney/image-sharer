require 'flow_test_helper'

class ImagesCrudTest < FlowTestCase
  def setup
    @user = User.create!(email: 'valid@email.com', password: 'password123')
  end

  def teardown
    Capybara.reset_sessions!
  end

  test 'add an image' do
    sessions_new_page = PageObjects::Sessions::NewPage.visit

    images_index_page = sessions_new_page.log_in!(email: @user.email, password: 'password123')
    assert_equal 'Successfully signed in!', images_index_page.flash_message(:success)

    new_image_page = images_index_page.add_new_image!

    tags = %w(foo bar)
    new_image_page = new_image_page.add_image!(url: 'invalid', tags: tags.join(', '))
      .as_a(PageObjects::Images::NewPage)
    assert_equal 'must be a valid url', new_image_page.url.error_message
    assert_equal tags.join(', '), new_image_page.tag_list.value

    new_image_page = new_image_page.add_image!(url: 'thisis.com/invalid?', tags: tags.join(', '))
      .as_a(PageObjects::Images::NewPage)
    assert_equal 'Please review the problems below:', new_image_page.form_error_message
    assert_equal 'must be a valid url', new_image_page.url.error_message
    assert_equal tags.join(', '), new_image_page.tag_list.value

    image_url = 'https://media.giphy.com/media/rl0FOxdz7CcxO/giphy.gif'
    new_image_page.url.set(image_url)

    image_show_page = new_image_page.add_image!
    assert_equal 'Url successfully saved!', image_show_page.flash_message(:success)

    assert_equal image_url, image_show_page.image_url
    assert_equal tags, image_show_page.tags

    images_index_page = image_show_page.go_back_to_index!
    assert images_index_page.showing_image?(url: image_url, tags: tags)
  end

  test 'add image and then update its tags' do
    image_url = 'https://media.giphy.com/media/rl0FOxdz7CcxO/giphy.gif'
    tags = %w(foo bar)

    image = Image.create!(url: image_url, tag_list: tags, user_id: @user.id)

    image_show_page = PageObjects::Images::ShowPage.visit(image)

    edit_image_page = image_show_page.edit_tags!

    edit_image_page.tag_list.set('')

    edit_image_page = edit_image_page.update!.as_a(PageObjects::Images::EditPage)
    assert_equal 'Please review the problems below:', edit_image_page.form_error_message
    assert_equal 'must have at least one tag', edit_image_page.tag_list.error_message

    images_show_page = edit_image_page.update!(tags: 'new tag')

    assert_equal image_url, images_show_page.image_url
    assert_equal ['new tag'], images_show_page.tags
  end

  test 'delete an image' do
    nyan_cat_url = 'https://media.giphy.com/media/SdhYdt5jkOdnG/giphy.gif'
    mind_blown_url = 'https://media.giphy.com/media/EldfH1VJdbrwY/giphy.gif'
    Image.create!([
      { url: nyan_cat_url, tag_list: 'cat, wow, cool', user_id: @user.id },
      { url: mind_blown_url, tag_list: 'mind, totally, blown', user_id: @user.id }
    ])

    images_index_page = PageObjects::Images::IndexPage.visit
    assert_equal 2, images_index_page.images.count
    assert images_index_page.showing_image?(url: mind_blown_url)
    assert images_index_page.showing_image?(url: nyan_cat_url)

    image_to_delete = images_index_page.images.find do |image|
      image.url == mind_blown_url
    end
    image_show_page = image_to_delete.view!

    image_show_page.delete do |confirm_dialog|
      assert_equal 'Are you sure you want to delete this image?', confirm_dialog.text
      confirm_dialog.dismiss
    end
    assert_equal mind_blown_url, image_show_page.image_url

    images_index_page = image_show_page.delete_and_confirm!
    assert_equal 'Image successfully deleted!', images_index_page.flash_message(:success)

    assert_equal 1, images_index_page.images.count
    refute images_index_page.showing_image?(url: mind_blown_url)
    assert images_index_page.showing_image?(url: nyan_cat_url)
  end

  test 'view images associated with a tag' do
    puppy_url_1 = 'http://www.pawderosa.com/images/puppies.jpg'
    puppy_url_2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    Image.create!([
      { url: puppy_url_1, tag_list: 'superman, cute', user_id: @user.id },
      { url: puppy_url_2, tag_list: 'cute, puppy', user_id: @user.id },
      { url: cat_url, tag_list: 'cat, ugly', user_id: @user.id }
    ])

    images_index_page = PageObjects::Images::IndexPage.visit
    [puppy_url_1, puppy_url_2, cat_url].each do |url|
      assert images_index_page.showing_image?(url: url)
    end

    images_index_page = images_index_page.images[1].click_tag!('cute')

    assert_equal 2, images_index_page.images.count
    refute images_index_page.showing_image?(url: cat_url)

    images_index_page = images_index_page.clear_tag_filter!
    assert_equal 3, images_index_page.images.count
  end
end
