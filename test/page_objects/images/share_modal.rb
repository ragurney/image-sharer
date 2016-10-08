module PageObjects
  module Images
    class ShareModal < PageObjects::Document
      path :share_new_image
      path :share_send_image # If create fails

      form_for :share_form do
        element :email_address
        element :message
      end

      def image_url
        node.find('img')[:src]
      end

      def share_image!(email_address: nil, message: nil)
        self.email_address.set(url) if email_address.present?
        self.message.set(tags) if message.present?
        node.click_button('Share')
        window.change_to(IndexPage, self.class)
      end
    end
  end
end
