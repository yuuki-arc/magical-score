class User < ActiveRecord::Base
  attr_accessible :access_code, :password
  has_secure_password
  before_create { generate_token(:auth_token) }

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
  
  def self.authenticate(access_code, password)
    self.new(access_code, password)
  end
end
