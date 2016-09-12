module PageObjects
  module Images
    class IndexPage < PageObjects::Document
      path :images

      collection :images,
                 locator: '#images_list',
                 item_locator: '.js-image-card-container',
                 contains: ImageCard do
        def view!
          node.find('.js-image-link').click
          window.change_to(ShowPage)
        end

        def delete_image!
          node.click_on('Delete')
          yield node.session.driver.browser.switch_to.alert
          window.change_to(IndexPage)
        end

        def delete_image_and_confirm!
          node.click_on('Delete')
          alert = node.session.driver.browser.switch_to.alert
          alert.accept
          window.change_to(IndexPage)
        end
      end

      def add_new_image!
        node.click_on('New Image')
        window.change_to(NewPage)
      end

      def showing_image?(url:, tags: nil)
        images.any? do |image|
          result = image.url == url
          tags.present? ? (result && image.tags == tags) : result
        end
      end

      def clear_tag_filter!
        node.click_on('All Images')
        window.change_to(IndexPage)
      end
    end
  end
end
