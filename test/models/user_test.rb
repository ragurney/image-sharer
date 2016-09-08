require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'create valid user' do
    user = User.new(email: 'Steve@gmail.com', password: 'password123')
    assert_predicate user, :valid?
  end

  test 'create valid user with min number of password characters' do
    user = User.new(email: 'Steve@gmail.com', password: 'password')
    assert_predicate user, :valid?
  end

  test 'create user with invalid email' do
    [nil, '', 'invalid'].each do |value|
      user = User.new(email: value, password: 'password')
      assert_predicate user, :invalid?
      assert_equal ['is an invalid email address'], user.errors.messages[:email]
    end
  end

  test 'create invalid user with already taken email' do
    User.create!(email: 'valid@email.com', password: 'password123')
    user = User.new(email: 'valid@email.com', password: '123password')

    assert_predicate user, :invalid?
    assert_equal ['has already been taken'], user.errors.messages[:email]
  end

  test 'create user with blank password' do
    [nil, ''].each do |value|
      user = User.new(email: 'valid@valid.com', password: value)
      assert_predicate user, :invalid?
      assert_equal ['is too short (minimum is 8 characters)', "can't be blank"], user.errors.messages[:password]
    end
  end

  test 'create user with mismatched password / confirm password' do
    user = User.new(email: 'valid@valid.com', password: 'password', password_confirmation: 'word')
    assert_predicate user, :invalid?
    assert_equal ["doesn't match Password"], user.errors.messages[:password_confirmation]
  end

  test 'create user with too short of a password' do
    user = User.new(email: 'valid@valid.com', password: 'shorter')
    assert_predicate user, :invalid?
    assert_equal ['is too short (minimum is 8 characters)'], user.errors.messages[:password]
  end

  test 'create user downcases email address' do
    email = 'vAlId@email.com'
    user = User.create!(email: email, password: 'password123')
    assert_equal email.downcase, user.email
  end
end
