require 'uri'

class Image < ActiveRecord::Base
  belongs_to :user
  acts_as_taggable
  validates :url, presence: true, url: { allow_blank: true, message: 'must be a valid url' }
  validates :tag_list, presence: { message: 'must have at least one tag' }
end
