class ShareForm
  include ActiveModel::Model

  attr_accessor :email_address, :message

  validates :email_address, presence: true, email: true
end
