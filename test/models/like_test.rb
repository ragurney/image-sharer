require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: 'valid@user.com', password: 'password')
    @image = Image.create!(url: 'https://valid.com/p.png', tag_list: 'tag', user_id: @user.id)
  end

  test 'a like should be valid if supplied a user and image' do
    like = Like.create(user: @user, image: @image)

    assert_predicate like, :valid?
  end

  test 'a like should have to belong to an image' do
    like = Like.create(user: @user)

    refute_predicate like, :valid?
    assert_equal ['must exist', "can't be blank"], like.errors.messages[:image]

    like[:image_id] = @image.id
    assert_predicate like, :valid?
  end

  test 'a like should have to belong to a user' do
    like = Like.create(image: @image)

    refute_predicate like, :valid?
    assert_equal ['must exist', "can't be blank"], like.errors.messages[:user]

    like[:user_id] = @user.id
    assert_predicate like, :valid?
  end

  test 'an image like count should be updated with each like created/destroyed' do
    like = Like.new(user: @user, image: @image)

    assert_difference '@image.likes_count', 1 do
      like.save
    end

    assert_difference '@image.likes_count', -1 do
      like.destroy
    end
  end

  test 'should not be able to create duplicate likes' do
    users = User.create!([
      { email: 'valid@email.com', password: 'password123' },
      { email: 'valid1@email.com', password: 'password123' }
    ])
    image = Image.create!(url: 'https://valid.com/p.png', tag_list: 'tag', user_id: users[0].id)

    like = Like.new(image: image, user: users[0])
    assert_predicate like, :save

    like = Like.new(image: image, user: users[0])
    refute_predicate like, :save
    assert_equal ['has already been taken'], like.errors.messages[:user]

    like = Like.new(image: image, user: users[1])
    assert_predicate like, :save
  end
end
