module PageObjects
  module Images
    class ShowPage < PageObjects::Document
      path :image

      element :image,
              locator: '.js-image-card-container',
              is: ImageCard

      delegate :delete, :delete_and_confirm!, to: :image

      def image_url
        node.find('img')[:src]
      end

      def tags
        node.all('.image-tag').map(&:text)
      end

      def go_back_to_index!
        node.click_on('Image-Tiles')
        window.change_to(IndexPage)
      end
    end
  end
end
