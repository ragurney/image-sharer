module PageObjects
  module Users
    class NewPage < PageObjects::Document
      path :new_user
      path :users # if create fails

      form_for :user do
        element :email
        element :password
        element :password_confirmation
      end

      def form_error_message
        node.find('.alert.alert-danger').text
      end

      def sign_up!
        node.click_on('Sign up')
        window.change_to(Images::IndexPage, self.class)
      end
    end
  end
end
