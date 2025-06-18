class User < ApplicationRecord
  # RAILS MAGIC: ApplicationRecord gives us database connection, validations, 
  # callbacks, and all ActiveRecord methods (save, find, etc.)
  
  # attr_accessor creates getter/setter methods for remember_token
  # This is NOT stored in database - it's temporary, only in memory
  # Used to hold the plain-text token before we hash it
  attr_accessor :remember_token

  # RAILS CALLBACK: This runs automatically before every save
  # Ensures all emails are stored in lowercase for consistency
  before_save { self.email = email.downcase }

  # RAILS VALIDATIONS: These run before saving and stop save if they fail
  validates :name, presence: true, length: { maximum: 50 }
  
  # Regular expression to validate email format
  # \A = start of string, \z = end of string (more secure than ^ and $)
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, 
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false } # Creates database index
  
  # Password validation: allow_nil: true means existing users don't need 
  # to re-enter password when updating other fields
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # RAILS MAGIC: has_secure_password does A LOT:
  # 1. Expects a 'password_digest' column in database
  # 2. Creates password= and password_confirmation= setter methods
  # 3. Creates password and password_confirmation getter methods  
  # 4. Creates authenticate(password) method for login
  # 5. Automatically hashes passwords using BCrypt
  # 6. validations: false disables built-in validations (we use custom ones)
  has_secure_password validations: false
  
  # CUSTOM VALIDATION METHODS (called by validate declarations below)
  validate :password_present
  validate :password_confirmation_matches, if: :password_digest_changed?

  # CLASS METHODS (called on User class, not instances)
  # Self means "this class" (User), not an instance of User
  
  # Creates a secure hash from any string using BCrypt
  # Cost determines how slow/secure the hashing is
  # In tests, use min_cost for speed; in production, use normal cost for security
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Generates a random, URL-safe token (like "abc123XYZ")
  # Used for remember tokens, activation tokens, etc.
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # INSTANCE METHODS (called on specific User objects)
  
  # "Remember" a user by creating a remember token and storing its digest
  # Flow: generate token -> hash it -> store hash in database -> keep token in memory
  def remember
    # Generate new random token and store in memory (not database)
    self.remember_token = User.new_token
    # Hash the token and save to database (update_attribute skips validations)
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Generic authentication method - works with any type of token
  # This is the method you were asking about!
  def authenticated?(attribute, token)
    # Dynamic method calling: if attribute is :remember, calls self.remember_digest
    # if attribute is :password, calls self.password_digest, etc.
    digest = self.send("#{attribute}_digest")
    
    # Safety check: if no digest exists, authentication fails
    return false if digest.nil?
    
    # BCrypt magic: compares plain token with hashed digest
    # Returns true if they match, false otherwise
    BCrypt::Password.new(digest).is_password?(token)
  end

  # "Forget" a user by removing their remember digest from database
  def forget
    update_attribute(:remember_digest, nil)
  end

  private

  # CUSTOM VALIDATION METHODS
  # These run during validation and add errors if conditions aren't met
  
  # Ensures password is present when creating new users
  # (allow_nil: true in validates doesn't work for new records)
  def password_present
    errors.add(:password, "can't be blank") if password_digest.blank?
  end

  # Ensures password and password_confirmation match
  # Only runs if password_digest was changed (avoiding unnecessary checks)
  def password_confirmation_matches
    if password.present? && password != password_confirmation
      errors.add(:password_confirmation, "doesn't match password")
    end
  end
end
