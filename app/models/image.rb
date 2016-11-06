require 'uri'

class Image < ActiveRecord::Base
  belongs_to :user
  has_many :likes, dependent: :destroy
  acts_as_taggable

  validates :url, presence: true, url: { allow_blank: true, message: 'must be a valid url' }
  validates :tag_list, presence: { message: 'must have at least one tag' }

  def liked_by?(current_user)
    current_user.nil? ? false : Like.exists?(image: self, user: current_user)
  end
end
