require 'flow_test_helper'

class ImagesFlowTest < FlowTestCase
  setup do
    @valid_url = 'http://digital-photography-school.com/wp-content/uploads/2007/02/black-and-white-tips.jpg'
    @invalid_url = 'asdf https://oh_no.this/?is_not_valid'
  end

  test 'add valid image and display' do
    visit(new_image_path)

    fill_in('image[url]', with: @valid_url)
    click_button('Upload Image')

    assert (has_current_path? image_path(1)), 'should redirect correctly'
    assert has_css?("img[src='#{@valid_url}']"), 'should display correct image'
    assert page.has_content?('Url successfully saved!'), 'should show success flash message'

    visit(root_path)
    assert (has_current_path? root_path), 'root path should exist'
    assert has_css?("img[src='#{@valid_url}']"), 'home page should list added image'
  end

  test 'add invalid (null) url, should redirect to new and show error' do
    visit(new_image_path)
    click_button('Upload Image')

    assert page.has_content?("can't be blank"), 'should show correct error message'
    assert has_css?("form[action='/images']"), 'should have new image form'

    visit(root_path)
    assert (has_current_path? root_path), 'root path should exist'
    refute has_css?("img[src='#{@valid_url}']"), 'home page should not list image with invalid url'
  end
end
