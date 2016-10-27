require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  test 'session form valid when email and password are present' do
    session = Session.new(email: 'valid@email.com', password: 'password123')
    assert_predicate session, :valid?
  end

  test 'session form invalid when email is missing' do
    session = Session.new(email: '', password: 'password123')
    assert_predicate session, :invalid?
    assert_equal ["can't be blank"], session.errors[:email]
  end

  test 'session form invalid when password is missing' do
    session = Session.new(email: 'valid@email.com', password: '')
    assert_predicate session, :invalid?
    assert_equal ["can't be blank"], session.errors[:password]
  end
end
