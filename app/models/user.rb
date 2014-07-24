class User < ActiveRecord::Base
  def self.authenticate(name, password)
    where(:name => name,
      :password => password).first
      #:password => Digest::SHA1.hexdigest(password)).first
  end
end
