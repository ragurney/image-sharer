require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test 'check url valid' do
    valid_urls.each do |url|
      extensions.each do |ext|
        img = Image.new(url: "#{url}#{ext}")
        assert img.valid?
      end
    end
  end

  test 'check url invalid' do
    invalid_urls.each do |url|
      extensions.each do |ext|
        img = Image.new(url: "#{url}#{ext}")
        refute img.valid?
        assert_equal ['must be a valid url'], img.errors.messages[:url]
      end
    end
  end

  test 'url invalid with no extension' do
    valid_urls.each do |url|
      img = Image.new(url: "#{url}")
      refute img.valid?
      assert_equal ['must be a valid url'], img.errors.messages[:url]
    end
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

  private

  def valid_urls
    ['http://thisis.com/?valid_yay', 'http://thisis.com/?valid_yay']
  end

  def invalid_urls
    ['thisis.com/?invalid', 'asdf https://thisis.com?invalid']
  end

  def extensions
    ['.jpg', '.png', '.gif']
  end
end
