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
    img = Image.new(url: '')
    refute img.valid?
    assert_equal ["can't be blank"], img.errors.messages[:url]
  end

  test 'url invalid null' do
    img = Image.new
    refute img.valid?
    assert_equal ["can't be blank"], img.errors.messages[:url]
  end
end
