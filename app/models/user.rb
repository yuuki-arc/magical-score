class User
  attr_accessor :access_code, :password

  def initialize(access_code, password)
    @access_code = access_code
    @password = password
  end

  def self.authenticate(access_code, password)
    self.new(access_code, password)
  end
end