module PageObjects
  module Images
    class EditPage < PageObjects::Document
      path :edit_image
      path :image

      form_for :image do
        element :tag_list
      end

      def form_error_message
        node.find('.alert.alert-danger').text
      end

      def update!(tags: nil)
        tag_list.set(tags) if tags.present?
        node.click_button('Update')
        window.change_to do |query|
          query.matches(ShowPage) { |show_page| show_page.find('.js-image-card-container').present? }
          query.matches(self.class) { |edit_page| edit_page.find('form').present? }
        end
      end
    end
  end
end
