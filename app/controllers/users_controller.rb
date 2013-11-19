class UsersController < ApplicationController
  include ApplicationHelper

  def index
    @title = 'User management'

    if request.post?
      page = 0
      page = (params[:page].to_i - 1) if params[:page].present?
      users_per_page = 5

      # I DON'T WANT TO DO THIS
      if params[:search] == "*"
        @users = User.find(:all, :filter => "(!(zarafaResourceType=*))")
      else
        @users = User.find(:all, :filter => "(&(|(uid=*#{params[:search]}*)(cn=*#{params[:search]}*)(mail=*#{params[:search]}*))(!(zarafaResourceType=*))")
      end
#      @pages = paginate(users_per_page, @users.length, page)
#      @users = @users.slice(users_per_page * page, users_per_page)
      render :partial => "users", :layout => false
    end
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
    @user.sn = user_params[:sn]
    @user.displayName = "#{user_params[:givenName]} #{user_params[:sn]}" unless user_params[:givenName].empty? and user_params[:sn].empty?
    @user.commonName = @user.displayName
    @user.zarafaAccount = 1;
    @user.zarafaAdmin = user_params[:zarafaAdmin]
    @user.zarafaHidden = user_params[:zarafaHidden]
    @user.gidNumber = 1000;
    @user.homeDirectory = '/dev/null'
    @user.uidNumber = next_uidnumber
    @user.zarafaQuotaSoft = user_params[:zarafaQuotaSoft]
    @user.zarafaQuotaHard = user_params[:zarafaQuotaHard]

    if @user.valid?
      defgroup = Group.find(:first, :attribute => "cn", :value => "all");
      defgroup.members << @user

      if @user.save
        flash[:success] = "User '#{@user.uid}' was successfully created."
        redirect_to users_path and return
      end
    else
      @messages[:danger] = 'Some fields are in error, unable to save the user'
    end

    render :new
  end

  def edit
    @user = User.find(params[:uid])
    users_list = dn_to_uid @user.zarafaSendAsPrivilege(true) unless @user.zarafaSendAsPrivilege.nil?
    @user.zarafaSendAsPrivilege = users_list.to_json
    @title = "Edit user #{@user.uid}"
    @message = :message
  end

  def update
    @user = User.find(params[:uid])
    @user.mail = user_params[:mail]
    @user.zarafaAliases = user_params[:zarafaAliases]
    @user.givenName = user_params[:givenName]
    @user.sn = user_params[:sn]
    @user.displayName = "#{user_params[:givenName]} #{user_params[:sn]}"
    @user.commonName = @user.displayName
    @user.zarafaSendAsPrivilege = uid_to_dn user_params[:zarafaSendAsPrivilege] unless user_params[:zarafaSendAsPrivilege].nil?
    @user.zarafaAdmin = user_params[:zarafaAdmin]
    @user.zarafaHidden = user_params[:zarafaHidden]
    @user.zarafaQuotaSoft = user_params[:zarafaQuotaSoft]
    @user.zarafaQuotaHard = user_params[:zarafaQuotaHard]

    if ! user_params[:userPassword].empty?
      require 'securerandom'

      # salt = SecureRandom.urlsage_base64(12)
      salt = 'azerty'
      digest = Base64.encode64(Digest::SHA1.digest(user_params[:userPassword] + salt) + salt).chomp
      
      @user.userPassword = '{SSHA}' + digest
    end

    if @user.valid?
      if @user.save
        flash[:success] = "User '#{@user.uid}' was successfully edited."
        redirect_to users_path and return
      end
    else
      @messages[:danger] = 'Some fields are in error, unable to save the user'
    end

    @user.zarafaSendAsPrivilege = dn_to_uid @user.zarafaSendAsPrivilege unless @user.zarafaSendAsPrivilege.nil?

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
    users_list = User.find(:all, :filter => "(|(uid=*#{params[:q]}*)(cn=*#{params[:q]}*)(mail=*#{params[:q]}*))")
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
                                 :sn,
                                 :mail,
                                 :userPassword,
                                 :zarafaAdmin,
                                 :zarafaHidden,
                                 :zarafaQuotaSoft,
                                 :zarafaQuotaHard,
                                 :zarafaAliases => [],
                                 :zarafaSendAsPrivilege => [],
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

    unless data.empty?
      data = data[0].split(",")
    end
 
    data.map! { | uid |
      privilege_user = User.find(uid)

      'uid=' << privilege_user.uid << ',' << privilege_user.base
    }
  end

  def next_uidnumber
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
