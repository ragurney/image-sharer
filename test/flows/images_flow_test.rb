require 'flow_test_helper'

class ImagesFlowTest < FlowTestCase
  setup do
    @valid_url = 'http://digital-photography-school.com/wp-content/uploads/2007/02/black-and-white-tips.jpg'
    @invalid_url = 'asdf https://oh_no.this/?is_not_valid'
  end

  test 'add valid image and display, then check deletion functionality' do
    visit(new_image_path)

    fill_in('image[url]', with: @valid_url)
    click_button('Upload Image')

    assert (has_current_path? image_path(1)), 'should redirect correctly'
    assert has_css?("img[src='#{@valid_url}']"), 'should display correct image'
    assert page.has_content?('Url successfully saved!'), 'should show success flash message'

    visit(images_path)
    assert (has_current_path? images_path), 'root path should exist'
    assert has_css?("img[src='#{@valid_url}']"), 'home page should list added image'

    click_link('Delete')
    dialog = page.driver.browser.switch_to.alert
    assert_equal 'Are you sure you want to delete this image?', dialog.text
    dialog.dismiss
    assert has_css?("img[src='#{@valid_url}']"), 'home page should still have image'

    click_link('Delete')
    dialog = page.driver.browser.switch_to.alert
    dialog.accept
    assert has_no_css?("img[src='#{@valid_url}']")
  end

  test 'add invalid (null) url, should redirect to new and show error' do
    visit(new_image_path)
    click_button('Upload Image')

    assert page.has_content?("can't be blank"), 'should show correct error message'
    assert has_css?("form[action='/images']"), 'should have new image form'

    visit(images_path)
    assert (has_current_path? images_path), 'root path should exist'
    assert has_no_css?("img[src='#{@valid_url}']"), 'home page should not list image with invalid url'
  end

  test 'create images with different tags then check for correct filtering' do
    visit(new_image_path)
    fill_in('image[url]', with: @valid_url)
    fill_in('image[tag_list]', with: 'tag1, tag3')
    click_button('Upload Image')
    visit(new_image_path)
    fill_in('image[url]', with: @valid_url + '1')
    fill_in('image[tag_list]', with: 'tag1, tag2')
    click_button('Upload Image')
    visit(new_image_path)
    fill_in('image[url]', with: @valid_url + '2')
    fill_in('image[tag_list]', with: '')
    click_button('Upload Image')

    visit(images_path)
    click_link('tag2')
    assert has_css?("img[src='#{@valid_url}1']")
  end

  test 'first add tags with invalid url, then add image with tags and confirm tag presence' do
    tags = %w(cool car stuff)

    visit(new_image_path)

    fill_in('image[url]', with: @invalid_url)
    fill_in('image[tag_list]', with: tags.join(', '))
    click_button('Upload Image')
    assert_equal tags.join(', '), find_field('image[tag_list]').value

    fill_in('image[url]', with: @valid_url)
    click_button('Upload Image')

    assert has_css?('.image-tag', count: 3)
    find_all('.image-tag').each_with_index do |span, i|
      assert_equal tags[i], span.text
    end
  end
end
