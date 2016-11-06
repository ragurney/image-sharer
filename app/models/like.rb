class Like < ApplicationRecord
  belongs_to :user
  belongs_to :image, counter_cache: true

  validates :image, presence: true
  validates :user, presence: true, uniqueness: { scope: :image }
end
