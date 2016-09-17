require 'test_helper'

class ShareFormTest < ActiveSupport::TestCase
  test 'valid share form' do
    form = ShareForm.new(email_address: 'valid@valid.com')
    assert_predicate form, :valid?
  end

  test 'blank email given to form' do
    [nil, ''].each do |value|
      form = ShareForm.new(email_address: value)

      assert_predicate form, :invalid?
      assert_equal ["can't be blank", 'is invalid'], form.errors[:email_address]
    end
  end

  test 'invalid email given to form' do
    form = ShareForm.new(email_address: 'invalid')

    assert_predicate form, :invalid?
    assert_equal ['is invalid'], form.errors[:email_address]
  end
end
