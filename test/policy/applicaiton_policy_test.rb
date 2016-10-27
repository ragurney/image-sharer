require 'test_helper'

class ApplicationPolicyTest < ActiveSupport::TestCase
  test 'initialize should assign vars correctly' do
    user_mock = mock
    record_mock = mock

    app_policy = ApplicationPolicy.new(user_mock, record_mock)
    assert_equal user_mock, app_policy.user
    assert_equal record_mock, app_policy.record
  end

  test 'show? should return true if record exists in db' do
    user = User.create!(email: 'valid@email.com', password: 'password123')
    image = Image.create!(url: 'https://url.com/p.png', tag_list: 'tag', user_id: user.id)

    policy = ApplicationPolicy.new(user, image)
    assert_predicate policy, :show?
  end

  test 'show? should return false if record does not exist in db' do
    policy = ApplicationPolicy.new(mock, mock(class: Image, id: -1))
    refute_predicate policy, :show?
  end

  test 'new? should call create?' do
    policy = ApplicationPolicy.new(mock, mock)
    policy.expects(:create?).returns(true)
    assert_predicate policy, :new?
  end

  test 'edit? should call update?' do
    policy = ApplicationPolicy.new(mock, mock)
    policy.expects(:update?).returns(true)
    assert_predicate policy, :edit?
  end
end
