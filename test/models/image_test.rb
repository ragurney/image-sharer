require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  def test_url__invalid
    img = Image.new
    refute img.valid?
  end

  def test_url__valid
    img = Image.new(url: 'http://placehold.it/120x120&text=image1')
    assert img.valid?
  end
end
