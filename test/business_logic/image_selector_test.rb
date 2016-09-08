require 'test_helper'

class ImageSelectorTest < ActiveSupport::TestCase
  test 'should show all images when pass nil for tags' do
    image3 = Image.create!(url: 'http://www.validurl.com/image2.png', tag_list: nil,
                           created_at: Time.zone.now)
    image1 = Image.create!(url: 'http://www.validurl.com/image.png', tag_list: 'tag1, tag2, tag3',
                           created_at: Time.zone.now - 3.days)
    image2 = Image.create!(url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag2',
                           created_at: Time.zone.now - 2.days)

    result = ImageSelector.select nil
    expected = [image3, image2, image1]

    assert_equal expected, result
  end

  test 'should show specified image when tag is selected' do
    Image.create!(url: 'http://www.validurl.com/image2.png', tag_list: nil,
                  created_at: Time.zone.now)
    image1 = Image.create!(url: 'http://www.validurl.com/image.png', tag_list: 'tag1, tag2, tag3',
                           created_at: Time.zone.now - 3.days)
    image2 = Image.create!(url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag2',
                           created_at: Time.zone.now - 2.days)
    Image.create!(url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag3',
                  created_at: Time.zone.now - 1.day)

    result = ImageSelector.select 'tag2'
    expected = [image2, image1]

    assert_equal expected, result
  end

  test 'should show no images when invalid tag is passed' do
    Image.create!(url: 'http://www.validurl.com/image2.png', tag_list: nil,
                  created_at: Time.zone.now)
    Image.create!(url: 'http://www.validurl.com/image.png', tag_list: 'tag1, tag2, tag3',
                  created_at: Time.zone.now - 3.days)
    Image.create!(url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag2',
                  created_at: Time.zone.now - 2.days)
    Image.create!(url: 'http://www.validurl.com/image1.png', tag_list: 'tag1, tag3',
                  created_at: Time.zone.now - 1.day)

    result = ImageSelector.select 'invalid'

    assert result.empty?
  end
end
