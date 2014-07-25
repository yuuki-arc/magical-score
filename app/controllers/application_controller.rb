class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_logined
  layout 'slate'

  http_basic_authenticate_with :name => ENV["BASIC_AUTH_NAME"], :password => ENV["BASIC_AUTH_PW"] if Rails.env.production?

  private
  def current_user
    @current_user ||= User.find_by_auth_token( cookies[:auth_token]) if cookies[:auth_token]
  end
  helper_method :current_user
  
  private
  def check_logined
    if session[:user] then
      @user = session[:user]
    end

    unless @user
      flash[:referer] = request.fullpath
      redirect_to :controller => 'login', :action => 'index'
    end
  end
end
