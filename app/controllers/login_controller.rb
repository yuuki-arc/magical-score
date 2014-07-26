class LoginController < ApplicationController
  skip_before_filter :check_logined

  def index
    @access_code = cookies[:access_code]
    @password = cookies[:password]
    render 'index'
  end
  
  def auth
    user = User.find_by_access_code(params[:access_code])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      session[:user] = user
      # redirect_to params[:referer]
      redirect_to :controller => 'music_lists', :action => 'index'
    else
      u = User.new(access_code: params[:access_code], password: params[:password])
      u.save!
      flash.now[:referer] = params[:referer]
      @access_code = cookies[:access_code]
      @password = cookies[:password]
      @error = 'アクセスコードまたはパスワードが一致しません。'
      render 'index'
    end
  end

  def logout
    cookies.delete(:auth_token)
    reset_session
    redirect_to '/'
  end
end
