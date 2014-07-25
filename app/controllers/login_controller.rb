class LoginController < ApplicationController
  skip_before_filter :check_logined

  def index
      render 'index'
  end
  
  def auth
    user = User.authenticate(params[:access_code], params[:password])
    if user then
      session[:user] = user
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