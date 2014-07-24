class LoginController < ApplicationController
  skip_before_filter :check_logined

  def index
      render 'index'
  end
  
  def auth
    user = User.authenticate(params[:name], params[:password])
    if user then
      session[:user] = user.id
      redirect_to params[:referer]
    else
      flash.now[:referer] = params[:referer]
      @error = 'username / password error'
      render 'index'
    end
  end

  def logout
    reset_session
    redirect_to '/'
  end
end
