require 'uri'

class Image < ActiveRecord::Base
  validates :url, presence: true
  validate :url_is_valid

  private

  def url_is_valid
    return unless url.present?

    errors.add(:url, 'must be a valid url') unless
      (File.extname(url) =~ /^(.png|.gif|.jpg)$/) && (url =~ /^#{URI.regexp}$/)
  end
end
