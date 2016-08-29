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
end
