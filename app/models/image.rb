require 'uri'

class Image < ActiveRecord::Base
  URL_REGEX = %r{ \A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)
                  *\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?(\/)?(.png|.jpg|.gif)\z }x

  validates :url, presence: true
  validates :url, format: { with: URL_REGEX, message: 'must be a valid url', if: :url? }
end
