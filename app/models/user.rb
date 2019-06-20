class User < ApplicationRecord

  has_many :microposts, dependent: :destroy

  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create  :create_activation_digest

  validates :name, presence: true, length: {maximum:50}
  VALID_EMAIL_REGEX=/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX},
  uniqueness: {case_sensitive: false}

  validates :password, length: {minimum: 6}, presence: true, allow_nil: true              
  has_secure_password

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  # return a random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute,token)
    digest = send ("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  

  def forget
    self.update_attribute(:remember_digest, nil)
  end


  def activate
    # update_attribute(:activated,    true)
    # update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end 

# Sets the password reset attributes
def create_reset_digest
  self.reset_token = User.new_token
  # update_attribute(:reset_digest, User.digest(reset_token))
  # update_attribute(:reset_sent_at, Time.zone.now)
  update_columns(:reset_digest => User.digest(reset_token), :reset_sent_at => Time.zone.now)
end

# Send password reset email
def send_password_reset_email
  UserMailer.password_reset(self).deliver_now
end

# Returns true if a password reset has expired
def password_reset_expired?
  # reset_send_at < 2.hours.ago
  return true if (Time.zone.now - self.reset_sent_at) > 7200 
end

# Defines a proto-feed.
# See "Following users" for the full implementation.
  def feed
    Micropost.where("user_id = ?", id)
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end
