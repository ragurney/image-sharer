require 'test_helper'

class ImagesControllerTest < ActionDispatch::IntegrationTest
  test 'should get images form page' do
    get new_image_path

    assert_response :ok
    assert_select 'h1', 1, 'New Image URL'
  end
end
