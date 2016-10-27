class Session
  include ActiveModel::Model
  validates :email, presence: true
  validates :password, presence: true

  attr_accessor :email, :password, :remember_me
end
