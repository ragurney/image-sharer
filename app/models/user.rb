class User < ApplicationRecord
  validates :email, uniqueness: true, email: { message: 'is an invalid email address' }
  validates :password, length: { minimum: 8 }
  has_secure_password

  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase
  end
end
