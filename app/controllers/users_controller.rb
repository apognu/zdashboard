class UsersController < ApplicationController
  include ApplicationHelper

  def index
    @title = 'User management'

    page = 0
    page = (params[:page].to_i - 1) if params[:page].present?
    users_per_page = 5

    # I DON'T WANT TO DO THIS
    @users = User.all
    @pages = paginate(users_per_page, @users.length, page)
    @users = @users.slice(users_per_page * page, users_per_page)
  end

  def new
    @title = 'Create a new user'

    @user = User.new
  end

  def save
    @title = 'Create a new user'

    @user = User.new(user_params[:uid])
    @user.mail = user_params[:mail]
    @user.givenName = user_params[:givenName]
    @user.surname = user_params[:surname]
    @user.displayName = "#{user_params[:givenName]} #{user_params[:surname]}"
    @user.commonName = @user.displayName

    if @user.valid?
      if @user.save
        flash[:success] = "User '#{@user.uid}' was successfully created."
        redirect_to users_path and return
      end
    end

    render :new
  end

  def edit
    @user = User.find(params[:uid])
    @user.zarafaSendAsPrivilege = dn_to_uid @user.zarafaSendAsPrivilege unless @user.zarafaSendAsPrivilege.nil?

    @title = "Edit user #{@user.uid}"
  end

  def update
    @user = User.find(params[:uid])
    @user.mail = user_params[:mail]
    @user.zarafaAliases = user_params[:zarafaAliases]
    @user.givenName = user_params[:givenName]
    @user.surname = user_params[:surname]
    @user.displayName = "#{user_params[:givenName]} #{user_params[:surname]}"
    @user.commonName = "#{user_params[:givenName]} #{user_params[:surname]}"
    @user.zarafaSendAsPrivilege = uid_to_dn user_params[:zarafaSendAsPrivilege] unless user_params[:zarafaSendAsPrivilege].nil?

    if @user.valid?
      if @user.save
        flash[:success] = "User '#{@user.uid}' was successfully edited."
        redirect_to users_path and return
      end
    end

    @user.zarafaSendAsPrivilege = user_params[:zarafaSendAsPrivilege]

    render :edit
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
                                 :zarafaAliases => [],
                                 :zarafaSendAsPrivilege => []
    )
  end

  def dn_to_uid data
    if data.kind_of?(Array)
      data.reject! { | x | x.nil? or x.empty? }

      data.map! { | dn |
        User.find(dn).uid
      }
    else
      User.find(data).uid
    end
  end

  def uid_to_dn data
    data.reject! { | x | x.nil? or x.empty? }

    data.map! { | uid |
      privilege_user = User.find(uid)

      'uid=' << privilege_user.uid << ',' << privilege_user.base
    }
  end
end
