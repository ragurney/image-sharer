module PageObjects
  module Images
    class ShareModal < AePageObjects::Element
      form_for :share_form do
        element :email_address
        element :message
      end

      def form_error_message
        node.find('.alert.alert-danger').text
      end

      def image_url
        node.find('img')[:src]
      end

      def share
        node.click_on('Share')
      end
    end
  end
end
