module PageObjects
  module Images
    class ShowPage < PageObjects::Document
      path :image

      def url?(url)
        node.find("img[src=\"#{url}\"]").present?
      end

      def tags
        node.all('.image-tag').map(&:text)
      end

      def delete
        node.click_on('Delete')
        yield node.driver.browser.switch_to.alert
      end

      def delete_and_confirm!
        node.click_on('Delete')
        alert = node.driver.browser.switch_to.alert
        alert.accept
        window.change_to(IndexPage)
      end

      def go_back_to_index!
        node.click_on('Image-Tiles')
        window.change_to(IndexPage)
      end
    end
  end
end
