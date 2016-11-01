require 'flow_test_helper'

class LikeImageTest < FlowTestCase
  def setup
    @user = User.create!(email: 'valid@email.com', password: 'password123')
  end

  def teardown
    Capybara.reset_sessions!
  end

  test 'try to like an image logged out -> log in -> like image -> unlike image' do
    image_urls = %w(https://valid.com/1 https://valid.com/2 https://valid.com/3)
    tags = %w(tag1 tag2 tag3)

    Image.create!(image_urls.zip(tags).map do |image|
                    {
                      url: image[0],
                      tag_list: image.drop(1),
                      user_id: @user.id
                    }
                  end)

    images_index_page = PageObjects::Images::IndexPage.visit

    image_to_like = images_index_page.images.find do |image|
      image.url == image_urls[0]
    end

    image_to_like.like
    images_index_page = AePageObjects.browser.current_window.change_to(PageObjects::Images::IndexPage)
    assert_equal 'You must log in to like images!', images_index_page.flash_message(:danger)

    sessions_new_page = PageObjects::Sessions::NewPage.visit
    images_index_page = sessions_new_page.log_in!(email: @user.email, password: 'password123')
    assert_equal 'Successfully signed in!', images_index_page.flash_message(:success)

    image_to_like = images_index_page.images.find do |image|
      image.url == image_urls[0]
    end

    image_to_like.like
    expected_like_vals = %w(0 0 1)
    images_index_page.images.each_with_index do |image, index|
      assert_equal expected_like_vals[index], image.like_count
    end

    image_to_like.like
    expected_like_vals = %w(0 0 0)
    images_index_page.images.each_with_index do |image, index|
      assert_equal expected_like_vals[index], image.like_count
    end
  end

  test 'try to like a nonexistent image' do
    image = Image.create!(url: 'https://valid.com/p.png', tag_list: 'tag', user_id: @user.id)

    images_show_page = PageObjects::Images::ShowPage.visit(image.id)

    image.destroy

    images_show_page.like
    images_index_page = AePageObjects.browser.current_window.change_to(PageObjects::Images::IndexPage)
    assert_equal 'The image you were looking for does not exist', images_index_page.flash_message(:danger)
  end
end
