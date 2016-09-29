module PageObjects
  module Sessions
    class NewPage < PageObjects::Document
      path :new_session

      form_for :session do
        element :email
        element :password
      end

      def sign_up!
        node.click_on('Sign up')
        window.change_to(Users::NewPage)
      end

      def log_in!(email: nil, password: nil)
        self.email.set(email) if email.present?
        self.password.set(password) if password.present?
        node.click_button('Log in')
        window.change_to(Images::IndexPage, self.class)
      end
    end
  end
end
