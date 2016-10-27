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
end
