require "bcrypt"

class User < ActiveRecord::Base
  attr_accessible :access_code, :password, :password_confirmation
  has_secure_password

  before_save do
    self.password_digest = BCrypt::Password.create(password)
  end 

  def authenticate(unencrypted_password)
    BCrypt::Password.new(password_digest) == unencrypted_password
  end
end