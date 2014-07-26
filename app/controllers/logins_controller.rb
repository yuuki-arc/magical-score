class LoginsController < ApplicationController
  skip_before_filter :check_logined

  def index
    @access_code = cookies[:access_code]
    @token = cookies[:token]
    render 'index'
  end

  def create
    is_login = false
    # ユーザー情報を取得
    if params[:use_token]
      user = User.find_by_auth_token params[:token]
      if user
        is_login = true
      end
    else
      user = User.find_by_access_code params[:access_code]
      if user && user.authenticate(params[:password])
        is_login = true
      end
    end
    # ログイン判定
    if is_login
      # ログインOKの場合は画面遷移
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      session[:user] = user
      redirect_to :controller => 'music_lists', :action => 'index'
    else
      # ログインNGの場合は自動登録して画面遷移
      user = User.new(access_code: params[:access_code], password: params[:password], password_confirmation: params[:password])
      user.save!
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end

      flash.now[:referer] = params[:referer]
      @access_code = cookies[:access_code]
      @token = cookies[:auth_token]
      @error = 'アクセスコードまたはパスワードが一致しなかったため新規登録しました。'
      render 'index'
    end
  end

  def destroy
    # cookies.delete(:auth_token)
    reset_session
    @current_user = nil
    redirect_to root_path
  end

  # def auth
  #   user = User.find_by_access_code(params[:access_code])
  #   if user && user.authenticate(params[:password])
  #     if params[:remember_me]
  #       cookies.permanent[:auth_token] = user.auth_token
  #     else
  #       cookies[:auth_token] = user.auth_token
  #     end
  #     session[:user] = user
  #     # redirect_to params[:referer]
  #     redirect_to :controller => 'music_lists', :action => 'index'
  #   else
  #     u = User.new(access_code: params[:access_code], password: params[:password])
  #     u.save!
  #     flash.now[:referer] = params[:referer]
  #     @access_code = cookies[:access_code]
  #     @password = cookies[:password]
  #     @error = 'アクセスコードまたはパスワードが一致しません。'
  #     render 'index'
  #   end
  # end

  # def logout
  #   cookies.delete(:auth_token)
  #   reset_session
  #   redirect_to '/'
  # end
end
