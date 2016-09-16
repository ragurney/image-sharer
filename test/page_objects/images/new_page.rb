module PageObjects
  module Images
    class NewPage < PageObjects::Document
      path :new_image
      path :images # if create fails

      form_for :image do
        element :url
        element :tag_list
      end

      def add_image!(url: nil, tags: nil)
        self.url.set(url) if url.present?
        tag_list.set(tags) if tags.present?
        node.click_button('Add Image')
        window.change_to(ShowPage, self.class) # Order aware
      end
    end
  end
end
