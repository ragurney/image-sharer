require 'flow_test_helper'

class SessionsTest < FlowTestCase
  def setup
    @user = User.create!(email: 'valid@email.com', password: 'password123')
  end

  def teardown
    Capybara.reset_sessions!
  end

  test 'login incorrectly with created user -> login successfully -> log out' do
    sessions_new_page = PageObjects::Sessions::NewPage.visit

    sessions_new_page = sessions_new_page.log_in!(
      email: @user.email,
      password: 'Not the password'
    ).as_a(PageObjects::Sessions::NewPage)

    assert_equal 'There was a problem with your username and/or password',
                 sessions_new_page.flash_message(:danger)

    images_index_page = sessions_new_page.log_in!(email: @user.email, password: 'password123')
    assert_equal 'Successfully signed in!', images_index_page.flash_message(:success)

    images_index_page = images_index_page.log_out!
    assert_equal 'Successfully logged out', images_index_page.flash_message(:success)
  end
end
