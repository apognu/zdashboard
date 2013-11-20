class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :authorize

  class InvalidCredentialsException < Exception
  end

  def initialize
    @breadcrumbs = []
    @messages = Hash.new

    super
  end

  def error_404
    @title = 'Page not found'
    @breadcrumbs.concat([ 'Page not found' ])
    @messages[:danger] = 'We are sorry but an error occured.'

    render :status => 404
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
      @messages[:danger] = 'We could not connect to the backend directory, try again later.' 

      render 'application/auth' and return
    end
  end

  def auth
    begin
      @title = 'Authentication'
      @breadcrumbs.concat([ 'Authentication' ])

      if @current_user.kind_of?(User)
        redirect_to :root and return
      end

      if request.post?
        raise RuntimeError, 'Both fields are mandatory, here.' if params.has_key?(:username) and (
                                                                  params[:username].empty? or
                                                                  params[:password].empty?)

        user = User.find(params[:username])

        ldap = LDAP::Conn.new YAML.load_file("#{Rails.root}/config/ldap.yml")[Rails.env]['host']
        ldap.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
        ldap.bind user.dn, params[:password]

        if ldap.bound?
          if user.zarafaAdmin == 1
            session[:user] = user.uid

            flash[:success] = 'You have successfully authenticated into Zarafa Dashboard.'

            redirect_to(session[:return_to]) and return
          else
            raise InvalidCredentialsException, 'You are not authorized to access this part of ZDashboard.'
          end
        else
          raise InvalidCredentialsException, 'The given credentials are incorrect.'
        end
      end

      session[:return_to] = request.original_url
      render 'application/auth' and return
    rescue RuntimeError => error
      @messages[:danger] = error
    rescue ActiveLdap::EntryNotFound, LDAP::ResultError
      @messages[:danger] = 'The given credentials are incorrect.'

      render 'application/auth' and return
    rescue InvalidCredentialsException => error
      @messages[:danger] = error

      render 'application/auth' and return
    end
  end

  def logout
    session[:user] = nil 

    redirect_to root_path
  end
end
