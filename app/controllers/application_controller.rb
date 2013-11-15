class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :authorize

  def initialize
    @messages = Hash.new
    super
  end

  def authorize
    begin
      if session[:user]
        if @current_user = User.find(session[:user])
          return true
        end
      end

      auth
    rescue ActiveLdap::ConnectionError
      @messages[:danger] = 'We could not connect to the backend direcotry, try again later.' 
      render 'application/auth' and return
    end
  end

  def auth
    begin
      raise RuntimeError, 'Both fields are mandatory, here.' if params.has_key?(:username) and
                                                                (params[:username].empty? or params[:password].empty?)

      if ! params[:username].nil? and ! params[:password].nil?
        user = User.find(params[:username])

        if '{sha256}' << Digest::SHA2.new.base64digest(params[:password]) == user.userPassword
          if user.zarafaAdmin
            session[:user] = user.uid

            redirect_to(session[:return_to]) and return
            return
          end
        end
      end

      session[:return_to] = request.original_url
      render 'application/auth' and return
    rescue RuntimeError => error
      @messages[:danger] = error
    end
  end

  def logout
    session[:user] = nil 

    redirect_to root_path
  end
end
