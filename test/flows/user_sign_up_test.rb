require 'flow_test_helper'

class UserSignUpTest < FlowTestCase
  def teardown
    Capybara.reset_sessions!
  end

  test 'user sign up with all valid information' do
    images_index_page = PageObjects::Images::IndexPage.visit

    sessions_new_page = images_index_page.log_in!.as_a(PageObjects::Sessions::NewPage)

    users_new_page = sessions_new_page.sign_up!

    users_new_page.email.set('valid@email.com')
    users_new_page = users_new_page.sign_up!.as_a(PageObjects::Users::NewPage)
    assert_equal 'valid@email.com', users_new_page.email.value
    assert_equal 'Please review the problems below:', users_new_page.form_error_message
    assert_equal 'is too short (minimum is 8 characters)', users_new_page.password.error_message

    users_new_page.email.set('valid@email.com')
    users_new_page.password.set('password123')
    users_new_page.password_confirmation.set('password123')
    images_index_page = users_new_page.sign_up!

    assert_equal 'User successfully created!', images_index_page.flash_message(:success)
  end
end
