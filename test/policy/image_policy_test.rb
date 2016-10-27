require 'test_helper'

class ImagePolicyTest < ActiveSupport::TestCase
  test 'create? returns false if no user is present' do
    policy = ImagePolicy.new(nil, nil)
    refute_predicate policy, :create?
  end

  test 'create? returns true if user is present' do
    policy = ImagePolicy.new(mock, nil)
    assert_predicate policy, :create?
  end

  test 'destroy? returns false if no user is present' do
    policy = ImagePolicy.new(nil, nil)
    refute_predicate policy, :destroy?
  end

  test 'destroy? returns true if user is present and record user matches current user' do
    user_mock = mock
    record_mock = mock(user: user_mock)

    policy = ImagePolicy.new(user_mock, record_mock)
    assert_predicate policy, :destroy?
  end

  test 'destroy? returns true if user is present and record user does not match current user' do
    user_mock = mock
    record_mock = mock(user: mock)

    policy = ImagePolicy.new(user_mock, record_mock)
    refute_predicate policy, :destroy?
  end

  test 'update? returns false if no user is present' do
    policy = ImagePolicy.new(nil, nil)
    refute_predicate policy, :update?
  end

  test 'update? returns true if user is present and record user matches current user' do
    user_mock = mock
    record_mock = mock(user: user_mock)

    policy = ImagePolicy.new(user_mock, record_mock)
    assert_predicate policy, :update?
  end

  test 'update? returns true if user is present and record user does not match current user' do
    user_mock = mock
    record_mock = mock(user: mock)

    policy = ImagePolicy.new(user_mock, record_mock)
    refute_predicate policy, :update?
  end
end
