class UsersController < ApplicationController
  include ApplicationHelper

  def index
    @title = 'User management'
    @breadcrumbs.concat([ crumbs[:users] ])

    if request.post?
      params[:search].gsub!("(", "\\(")
      params[:search].gsub!(")", "\\)")
      @users = User.find(:all, :filter => "(&(|(uid=*#{params[:search]}*)(cn=*#{params[:search]}*)(mail=*#{params[:search]}*@*))(!(zarafaResourceType=*)))")

      render :partial => "users", :layout => false
    end
  end

  def new
    @title = 'Create a new user'
    @breadcrumbs.concat([ crumbs[:users], 'Create a new user' ])

    @user = User.new
  end

  def save
    @title = 'Create a new user'

    @user = User.new(sanitize_dn(user_params[:uid]))
    @user.mail = user_params[:mail]
    @user.givenName = user_params[:givenName]
    @user.sn = user_params[:sn]
    @user.displayName = "#{user_params[:givenName]} #{user_params[:sn]}" unless user_params[:givenName].empty? and user_params[:sn].empty?
    @user.commonName = @user.displayName
    @user.zarafaAccount = 1;
    @user.zarafaAdmin = user_params[:zarafaAdmin]
    @user.zarafaHidden = user_params[:zarafaHidden]

    # Is this used?
    @user.gidNumber = 1000;
    @user.homeDirectory = '/dev/null'
    @user.uidNumber = next_uidnumber
    @user.zarafaQuotaSoft = user_params[:zarafaQuotaSoft].to_i
    @user.zarafaQuotaHard = user_params[:zarafaQuotaHard].to_i

    if @user.valid?
      group = Group.find(:first, :attribute => "cn", :value => "all");
      group.members << @user

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
    @breadcrumbs.concat([ crumbs[:users], "Edit user #{@user.uid}" ])
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
    @user.zarafaQuotaSoft = user_params[:zarafaQuotaSoft].to_i
    @user.zarafaQuotaHard = user_params[:zarafaQuotaHard].to_i

    if ! user_params[:userPassword].empty?
      require 'securerandom'

      salt = SecureRandom.urlsafe_base64(12)
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

    # Only one group?
    group = user.groups

    unless group.empty?
      group.each do | g |
        g.members = g.members.reject { |u| u == user }
        g.save
      end
    end

    if user.destroy
      flash[:success] = "User '#{user.uid}' was successfully deleted."

      redirect_to users_path
    end
  end

  def list
    users = User.find(:all, :filter => "(&(|(uid=*#{params[:q]}*)(cn=*#{params[:q]}*)(mail=*#{params[:q]}*@*))(!(zarafaResourceType=*)))")
    groups = Group.find(:all, :filter => "(&(cn=*#{params[:q]}*))")

    users.concat(groups)

    users.map! do | user |
      if user.is_a? User
        {
          'text' => user.cn,
          'id' => user.uid
        }
      else
        {
          'text' => user.cn,
          'id' => user.cn
        }
      end
    end

    render :json => users
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

    data.map! { | dn |
      if User.exists?(dn)
        user = User.find(dn)
      elsif Group.exists?(dn)
        user = Group.find(dn)
      end
      if user.is_a? User
        {
          "text" => user.cn,
          "id"   => user.uid
        }
      elsif user.is_a? Group
        {
          "text" => user.cn,
          "id" => user.cn
        }
      else 
        {
          "text" => "deleted user",
          "id" => "deleted user",
        } 
      end
    }
  end

  def uid_to_dn data
    data.reject! { | x | x.nil? or x.empty? }
    
    data = data[0].split(',') unless data.empty?

    data.map! { | uid |
     if User.exists?(uid)
       privilege_user = User.find(uid)

       'uid=' << privilege_user.uid << ',' << privilege_user.base
     elsif Group.exists?(uid) 
       privilege_user = Group.find(uid)

       'cn=' << privilege_user.cn << ',' << privilege_user.base
     end
    }
  end

  def next_uidnumber
    users = User.find(:all, :attribute => 'uidNumber')

    users.max_by { | user | user.uidNumber }.uidNumber + 1
  end

  def crumbs
    {
      :users    => { :title => 'Users management', :link => :users }
    }
  end
end
