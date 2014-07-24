class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :check_logined
  layout 'slate'

  http_basic_authenticate_with :name => ENV["BASIC_AUTH_NAME"], :password => ENV["BASIC_AUTH_PW"] if Rails.env.production?

  private
  def check_logined
    if session[:user] then
      begin
        @user = User.find(session[:user])
      rescue ActiveRecord::RecordNotFound
        reset_session
      end
    end

    unless @user
      flash[:referer] = request.fullpath
      redirect_to :controller => 'login', :action => 'index'
    end
  end
end
