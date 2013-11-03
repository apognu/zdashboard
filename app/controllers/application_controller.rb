class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :authorize

  def authorize
    if session[:user]
      if @current_user = User.find(session[:user])
        return true
      end
    end

    auth
  end

  def auth
    if ! params[:username].nil? and ! params[:password].nil?
      user = User.find(params[:username])

      if '{sha256}' << Digest::SHA2.new.base64digest(params[:password]) == user.userPassword
        session[:user] = user.uid

        redirect_to(session[:return_to]) and return
        return
      end
    end

    session[:return_to] = request.original_url

    render 'application/auth' and return
  end

  def logout
    session[:user] = nil 

    redirect_to root_path
  end
end
