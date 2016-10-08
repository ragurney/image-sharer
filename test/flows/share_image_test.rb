require 'flow_test_helper'

class ShareImageTest < FlowTestCase
  test 'share image' do
    happening_url = 'https://media.giphy.com/media/rl0FOxdz7CcxO/giphy.gif'
    mind_blown_url = 'https://media.giphy.com/media/EldfH1VJdbrwY/giphy.gif'
    Image.create!([
      { url: happening_url, tag_list: 'its, really, happening' },
      { url: mind_blown_url, tag_list: 'mind, totally, blown' }
    ])

    images_index_page = PageObjects::Images::IndexPage.visit

    image_to_share = images_index_page.images.find do |image|
      image.url == mind_blown_url
    end

    share_new_image_page = image_to_share.open_share_page!
    assert_equal mind_blown_url, share_new_image_page.image_url

    share_new_image_page = share_new_image_page.share_image!.as_a(PageObjects::Images::ShareModal)
    assert_equal 'Please review the problems below:', share_new_image_page.flash_message(:danger)
    assert_equal "can't be blank", share_new_image_page.email_address.error_message

    share_new_image_page.email_address.set('invalid_email')
    share_new_image_page = share_new_image_page.share_image!.as_a(PageObjects::Images::ShareModal)
    assert_equal 'Please review the problems below:', share_new_image_page.flash_message(:danger)
    assert_equal 'is invalid', share_new_image_page.email_address.error_message

    share_new_image_page.email_address.set('valid@email.com')
    share_new_image_page.message.set('Some message')
    images_index_page = share_new_image_page.share_image!
    assert_equal 'Email successfully sent!', images_index_page.flash_message(:success)
  end

  test 'share nonexistent image' do
    happening_url = 'https://media.giphy.com/media/rl0FOxdz7CcxO/giphy.gif'
    created_image = Image.create!(url: happening_url, tag_list: 'its, really, happening')

    images_index_page = PageObjects::Images::IndexPage.visit
    image_to_share = images_index_page.images.find do |image|
      image.url == happening_url
    end

    share_new_image_page = image_to_share.open_share_page!
    created_image.destroy!

    share_new_image_page.email_address.set('valid@email.com')
    share_new_image_page.message.set('Some message')

    images_index_page = share_new_image_page.share_image!
    assert_equal 'The image you were looking for does not exist', images_index_page.flash_message(:danger)
  end
end
