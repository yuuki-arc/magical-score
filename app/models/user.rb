class User
  attr_accessor :access_code, :password

  def initialize(params)
    @access_code = params[:access_code]
    @password = params[:password]
  end
end
