module PageObjects
  module Images
    class ImageCard < AePageObjects::Element
      def url
        node.find('img')[:src]
      end

      def tags
        node.all('.image-card__tag').map(&:text)
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

      def open_share_page!
        node.click_on('Share')
        window.change_to(ShareModal)
      end
    end
  end
end
