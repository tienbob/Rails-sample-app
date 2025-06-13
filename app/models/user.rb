class User < ApplicationRecord
  before_save { self.email = email.downcase }

  validates :name, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, 
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  has_secure_password validations: false
  
  validate :password_present
  validate :password_confirmation_matches, if: :password_digest_changed?

  private

  def password_present
    errors.add(:password, "can't be blank") if password_digest.blank?
  end

  def password_confirmation_matches
    if password.present? && password != password_confirmation
      errors.add(:password_confirmation, "doesn't match password")
    end
  end
end
