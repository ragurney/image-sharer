require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test 'check url valid' do
    image = Image.new(url: 'https://thisis.com/?stuff.png')
    assert_predicate image, :valid?
  end

  test 'check url invalid' do
    image = Image.new(url: 'thisis.com/?invalid.png')
    assert_predicate image, :invalid?
  end

  test 'url invalid with empty string' do
    image = Image.new(url: '')
    assert_predicate image, :invalid?
    assert_equal ["can't be blank"], image.errors.messages[:url]
  end

  test 'url invalid null' do
    image = Image.new
    assert_predicate image, :invalid?
    assert_equal ["can't be blank"], image.errors.messages[:url]
  end

  test 'check image with url and tag valid' do
    tags = %w(tag1 tag2 tag3)
    image = Image.new(url: 'https://thisis.com/?stuff.png', tag_list: tags.join(', '))
    assert_predicate image, :valid?
    image.tag_list.each_with_index do |tag, i|
      assert_equal tags[i], tag
    end
  end
end
