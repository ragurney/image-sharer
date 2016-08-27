require 'uri'

class Image < ActiveRecord::Base
  validates :url, presence: true, url: { allow_blank: true, message: 'must be a valid url' }
end
