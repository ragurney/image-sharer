require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: 'admin@email.com', password: 'password123')
  end

  test 'check url valid' do
    image = Image.new(url: 'https://thisis.com/?stuff.png', tag_list: 'tag', user_id: @user.id)
    assert_predicate image, :valid?
  end

  test 'check url invalid' do
    image = Image.new(url: 'thisis.com/?invalid.png', tag_list: 'tag', user_id: @user.id)
    assert_predicate image, :invalid?
  end

  test 'url invalid with empty string' do
    image = Image.new(url: '', tag_list: 'tag', user_id: @user.id)
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
    image = Image.new(url: 'https://thisis.com/?stuff.png', tag_list: tags.join(', '), user_id: @user.id)
    assert_predicate image, :valid?
    image.tag_list.each_with_index do |tag, i|
      assert_equal tags[i], tag
    end
  end

  test 'saved image should be valid with one tag' do
    image = Image.new(url: 'https://valid.com', tag_list: 'tag', user_id: @user.id)
    assert_predicate image, :valid?
  end

  test 'saved image should be invalid with less than one tag' do
    image = Image.new(url: 'https://valid.com', tag_list: '', user_id: @user.id)
    assert_predicate image, :invalid?
    assert_equal ['must have at least one tag'], image.errors.messages[:tag_list]
  end
end
