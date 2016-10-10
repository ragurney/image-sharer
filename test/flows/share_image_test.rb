require 'flow_test_helper'

class ShareImageTest < FlowTestCase
  test 'share image successfully from index page' do
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
    image_to_share.share do |modal|
      assert_equal mind_blown_url, modal.image_url
      modal.email_address.set('valid@email.com')
      modal.message.set('Message!')
      modal.share
    end
    assert_equal 'Email successfully sent!', images_index_page.flash_message(:success)

    image_to_share = images_index_page.images.find do |image|
      image.url == happening_url
    end
    images_show_page = image_to_share.view!
    images_show_page.share do |modal|
      assert_equal happening_url, modal.image_url
      assert_equal '', modal.email_address.value
      assert_equal '', modal.message.value

      modal.email_address.set('valid@email.com')
      modal.message.set('Message!')
      modal.share
    end
    assert_equal 'Email successfully sent!', images_show_page.flash_message(:success)
  end

  test 'share image with modal with inline errors' do
    happening_url = 'https://media.giphy.com/media/rl0FOxdz7CcxO/giphy.gif'
    mind_blown_url = 'https://media.giphy.com/media/EldfH1VJdbrwY/giphy.gif'
    images = Image.create!([
      { url: happening_url, tag_list: 'its, really, happening' },
      { url: mind_blown_url, tag_list: 'mind, totally, blown' }
    ])

    images_show_page = PageObjects::Images::ShowPage.visit(images[0])

    images_show_page.share do |modal|
      assert_equal happening_url, modal.image_url
      modal.share
      assert_equal 'Please review the problems below:', modal.form_error_message
      assert_equal "can't be blank", modal.email_address.error_message

      modal.email_address.set('invalid_email')
      modal.share
      assert_equal 'Please review the problems below:', modal.form_error_message
      assert_equal 'is invalid', modal.email_address.error_message

      modal.email_address.set('valid@email.com')
      modal.message.set('Some message')
      modal.share
    end

    assert_equal 'Email successfully sent!', images_show_page.flash_message(:success)
  end

  test 'share nonexistent image' do
    happening_url = 'https://media.giphy.com/media/rl0FOxdz7CcxO/giphy.gif'
    created_image = Image.create!(url: happening_url, tag_list: 'its, really, happening')

    images_index_page = PageObjects::Images::IndexPage.visit
    image_to_share = images_index_page.images.find do |image|
      image.url == happening_url
    end

    created_image.destroy

    modal = image_to_share.open_share_modal
    modal.email_address.set('valid@email.com')
    modal.message.set('Some message')
    modal.share

    images_index_page = AePageObjects.browser.current_window.change_to(PageObjects::Images::IndexPage)

    assert_equal 'The image you were looking for does not exist', images_index_page.flash_message(:danger)
  end
end
