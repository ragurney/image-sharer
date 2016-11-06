module PageObjects
  module Images
    class ImageCard < AePageObjects::Element
      def url
        node.find('img')[:src]
      end

      def tags
        node.all('.image-card__tag').map(&:text)
      end

      def like_count
        node.find('.js-like-count').text
      end

      def click_tag!(tag_name)
        node.find("a[href=\"/images?tag=#{tag_name}\"]").click
        window.change_to(IndexPage)
      end

      def delete
        node.click_on('Delete')
        yield node.session.driver.browser.switch_to.alert
      end

      def delete_and_confirm!
        delete(&:accept)
        window.change_to(IndexPage)
      end

      def open_share_modal
        node.click_on('Share')
        modal = document.element(locator: '#share_image_modal', is: ShareModal)
        modal.wait_until_visible
        modal
      end

      def share
        modal = open_share_modal
        yield modal
        modal.wait_until_hidden
      end

      def edit_tags!
        node.click_on('Edit Tags')
        window.change_to(EditPage)
      end

      def like
        node.find('.js-like-btn').click
      end
    end
  end
end
