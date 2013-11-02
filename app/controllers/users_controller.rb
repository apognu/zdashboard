class UsersController < ApplicationController
  include ApplicationHelper

  def index
    @title = 'User management'

    page = 0
    page = (params[:page].to_i - 1) if params[:page].present?
    users_per_page = 5

    @users = User.all
    @pages = paginate(users_per_page, @users.length, page)
    @users = @users.slice(users_per_page * page, users_per_page)
  end

  def new
    @title = 'Create a new user'
    @user = User.new
  end

  def save
    user = User.new(user_params[:uid])
    
    user.mail = user_params[:mail]
    user.givenName = user_params[:givenName]
    user.surname = user_params[:surname]

    user.displayName = "#{user_params[:givenName]} #{user_params[:surname]}"
    user.commonName = user.displayName

    if user.save
      flash[:success] = "User '#{user.uid}' was successfully created."
      redirect_to users_path
    end
  end

  def edit
    @user = User.find(params[:uid])

    @title = "Edit user #{@user.uid}"
  end

  def update
    user = User.find(params[:uid])

    user.mail = user_params[:mail]
    user.zarafaAliases = user_params[:zarafaAliases]
    user.givenName = user_params[:givenName]
    user.surname = user_params[:surname]

    user.displayName = "#{user_params[:givenName]} #{user_params[:surname]}"
    user.commonName = "#{user_params[:givenName]} #{user_params[:surname]}"

    if user.save
      flash[:success] = "User '#{user.uid}' was successfully edited."
      redirect_to users_path
    end
  end

  def delete
    user = User.find(params[:uid])

    if user.destroy
      flash[:success] = "User '#{user.uid}' was successfully deleted."
      redirect_to users_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:uid,
                                 :givenName,
                                 :surname,
                                 :mail,
                                 :zarafaAdmin,
                                 :zarafaAliases => []
    )
  end
end
