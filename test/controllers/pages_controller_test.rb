require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test 'should get index (i.e. root)' do
    get images_path
    assert_response :ok
    assert_select 'h1', 1
  end
end
