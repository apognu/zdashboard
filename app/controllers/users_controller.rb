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
    @user.zarafaAdmin = user_params[:zarafaAdmin]
    @user.zarafaHidden = user_params[:zarafaHidden]
    uidNumber = get_next_uidnumber
    @user.uidNumber = uidNumber

    defgroup = Group.find(:first, :attribute => "cn", :value => "all");

    defgroup.members << @user

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
    users_list = dn_to_uid @user.zarafaSendAsPrivilege(true) unless @user.zarafaSendAsPrivilege.nil?
    @user.zarafaSendAsPrivilege = users_list.to_json
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
    @user.zarafaAdmin = user_params[:zarafaAdmin]
    @user.zarafaHidden = user_params[:zarafaHidden]
    if @user.valid?
      if @user.save
        flash[:success] = "User '#{@user.uid}' was successfully edited."
        redirect_to users_path and return
      end
    end

    @user.zarafaSendAsPrivilege = dn_to_uid @user.zarafaSendAsPrivilege

    render :edit
  end

  def delete
    user = User.find(params[:uid])

    group = user.groups

    tmp = group[0].members.reject { |u| u == user }
    group[0].members = tmp
    if group[0].save and user.destroy
      flash[:success] = "User '#{user.uid}' was successfully deleted."
      redirect_to users_path
    end
  end

  def list
    users_list = User.find(:all, :attributes => ['uid', 'cn'], :value => "*#{params[:q]}*")
    list = []
    users_list.each do | user |
      tmp = {
        'text' => user.cn,
        'id' => user.uid
      }
      list.push(tmp)
    end
    render :json => list
  end

  private

  def user_params
    params.require(:user).permit(:uid,
                                 :givenName,
                                 :surname,
                                 :mail,
                                 :zarafaAdmin,
                                 :zarafaHidden,
                                 :zarafaAliases => [],
                                 :zarafaSendAsPrivilege => []
    )
  end

  def dn_to_uid data
    data.reject! { | x | x.nil? or x.empty? }

    list = []
    data.map! { | dn |
      u = User.find(dn)

      tmp = {
        "text" => u.cn,
        "id" => u.uid
      }
      list.push(tmp)
    }
    data = list
  end

  def uid_to_dn data
    data.reject! { | x | x.nil? or x.empty? }
    data = data[0].split(",")
 
    data.map! { | uid |
      privilege_user = User.find(uid)

      'uid=' << privilege_user.uid << ',' << privilege_user.base
    }
  end

  def get_next_uidnumber
    users = User.find(:all, :attribute => 'uidNumber')

    max = 0
    users.each do | u |
      if u.uidNumber > max
        max = u.uidNumber
      end
    end
    return max+1
  end

end
