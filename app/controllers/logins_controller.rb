class LoginsController < ApplicationController
  skip_before_filter :check_logined

  def index
    @access_code = cookies[:access_code]
    @password = cookies[:password]
    render 'index'
  end
  
  def auth
    @access_code = params[:access_code]
    @password = params[:password]
    if @access_code.present? && @password.present?
      cookies[:access_code] = @access_code
      cookies[:password] = @password
      session[:user] = User.new(params)
      # redirect_to params[:referer]
      redirect_to :controller => 'music_lists', :action => 'index'
    else
      flash.now[:referer] = params[:referer]
      @error = 'アクセスコードまたはパスワードが一致しません。'
      render 'index'
    end
  end

  def logout
    reset_session
    redirect_to '/'
  end
end