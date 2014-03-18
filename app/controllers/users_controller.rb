class UsersController < ApplicationController
  include ApplicationHelper
  include GroupsHelper

  def index
    @title = 'User management'
    @breadcrumbs.concat([ crumbs[:users] ])

    if request.post?
      params[:search].gsub!("(", "\\(")
      params[:search].gsub!(")", "\\)")
      @users = User.find(:all, :filter => "(&(|(uid=*#{params[:search]}*)(cn=*#{params[:search]}*)(mail=*#{params[:search]}*@*)(zarafaAliases=*#{params[:search]}*))(!(zarafaResourceType=*)))")
      @users.each do | u |
        begin
          quota = Quota.find_by uid: u.uid
          u.current_quota = quota.value
        rescue
          u.current_quota = "N.C."
        end
      end
      render :partial => "users", :layout => false
    end
  end

  def new
    @title = 'Create a new user'
    @breadcrumbs.concat([ crumbs[:users], 'Create a new user' ])

    @user = User.new
    @groups = ""

    @domains = Setting.find_by_key("domains")
    @user.domain = Setting.find_by_key("defaultDomain")
    @user.zarafaQuotaSoft = Setting.find_by_key("defaultQuotaSoft")
    @user.zarafaQuotaHard = Setting.find_by_key("defaultQuotaHard")

    unless @domains.nil?
      @domains = @domains.value
    end
    unless @user.domain.nil?
      @user.domain = @user.domain.value
    end
    unless @user.zarafaQuotaSoft.nil?
      @user.zarafaQuotaSoft = @user.zarafaQuotaSoft.value
    end
    unless @user.zarafaQuotaHard.nil?
      @user.zarafaQuotaHard = @user.zarafaQuotaHard.value
    end
  end

  def save
    @title = 'Create a new user'

    @user = User.new(sanitize_dn(user_params[:uid]))
    @user.mail = user_params[:mail] + "@" + user_params[:domain]
    @user.zarafaAliases = user_params[:zarafaAliases]
    @user.givenName = user_params[:givenName]
    @user.sn = user_params[:sn]
    @user.displayName = "#{user_params[:givenName]} #{user_params[:sn]}" unless user_params[:givenName].empty? and user_params[:sn].empty?
    @user.commonName = @user.displayName
    @user.zarafaAccount = 1;
    @user.zarafaAdmin = user_params[:zarafaAdmin]
    @user.zarafaHidden = user_params[:zarafaHidden]
    @user.zarafaSharedStoreOnly = user_params[:zarafaSharedStoreOnly]
    @user.groups = []

    # Is this used?
    @user.gidNumber = 1000;
    @user.homeDirectory = '/dev/null'
    @user.uidNumber = next_uidnumber
    @user.zarafaQuotaSoft = user_params[:zarafaQuotaSoft].to_i
    @user.zarafaQuotaHard = user_params[:zarafaQuotaHard].to_i

    passwords_ok = true

    if !user_params[:userPassword].empty? and !user_params[:userPassword_confirmation].empty? and user_params[:userPassword_confirmation] == user_params[:userPassword]
      require 'securerandom'

      salt = SecureRandom.urlsafe_base64(12)
      digest = Base64.encode64(Digest::SHA1.digest(user_params[:userPassword] + salt) + salt).chomp

      @user.userPassword = '{SSHA}' + digest
    else
      passwords_ok = false
    end

    @domains = Setting.find_by_key("domains").value
    mail_ok = true
    if user_params[:mail].empty? or !@domains.include?(@user.mail.split("@")[1])
      mail_ok = false
    end

    if @user.valid? and passwords_ok and mail_ok
      if ! user_params[:groups].nil?
        user_params[:groups].reject! { | x | x.nil? or x.empty? or x == "all" }

        unless user_params[:groups][0].nil?
          groups = user_params[:groups][0].split(',')
          @user.groups = groups.map! { | group |
            Group.find(group)
          }
        end
        add_to_group_all
      end

      if @user.save
        flash[:success] = "User '#{@user.uid}' was successfully created."

        redirect_to users_path and return
      end
    else
      if user_params[:userPassword].empty?
        @user.errors.add(:userPassword, "can't be empty")
      end
      if user_params[:userPassword_confirmation].empty?
        @user.errors.add(:userPassword_confirmation, "can't be empty")
      end
      if !user_params[:userPassword].empty? and !user_params[:userPassword_confirmation].empty? and user_params[:userPassword] != user_params[:userPassword_confirmation]
        @user.errors.add(:userPassword)
        @user.errors.add(:userPassword_confirmation)
      end
      unless mail_ok
        if user_params[:mail].empty?
          @user.errors.add(:mail, "can't be empty")
        else
          @user.errors.add(:domain, "is not in authorized list")
        end
      end
      @messages[:danger] = 'Some fields are in error, unable to save the user'
      @user.mail = @user.mail.split("@")[0]
    end

    render :new
  end

  def edit
    @user = User.find(params[:uid], :attributes => ["+", "*"])

    begin
      quota = Quota.find_by uid: @user.uid
      @user.current_quota = quota.value
    rescue
      @user.current_quota = "N.C."
    end
    users_list = dn_to_uid @user.zarafaSendAsPrivilege(true) unless @user.zarafaSendAsPrivilege.nil?

    @user.zarafaSendAsPrivilege = users_list.to_json

    groups = gid_to_select @user.groups
    @groups = groups.to_json

    begin
      oof = ActiveSupport::JSON.decode(%x{ #{Rails.root}/vendor/zarafa-get-oof #{@user.uid} })
      @user.out_of_office = oof['out_of_office']
      @user.out_message = oof['message']
      @user.out_subject = oof['subject']
    rescue
      @messages[:danger] = "WARNING : zarafa server is offline, some features could not work"
    end
    
    @title = "Edit user #{@user.uid}"
    @breadcrumbs.concat([ crumbs[:users], "Edit user #{@user.uid}" ])

    begin
      @last_logon = %x{ zarafa-admin --detail #{@user.uid} | grep 'Last logon:' }.split("\t").reject!{ |c| c.empty? }[1].strip.chomp
    rescue
      @last_logon = "never"
    end

    @domains = Setting.find_by_key("domains")
    unless @domains.nil?
      @domains = @domains.value
    end
    tmp = @user.mail.split("@")
    @user.mail = tmp[0]
    @user.domain = tmp[1]
  end

  def update
    @user = User.find(params[:uid], :attributes => ["+", "*"])
    @user.mail = user_params[:mail] + "@" + user_params[:domain]
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
    @user.zarafaSharedStoreOnly = user_params[:zarafaSharedStoreOnly]
    @user.groups = []
    @user.out_of_office = user_params[:out_of_office]
    @user.out_message = user_params[:out_message]
    @user.out_subject = user_params[:out_subject]
    file = File.new("#{Dir.tmpdir}/#{@user.uid}_message", "w", 0777)
    file.write("#{@user.out_message}")
    file.close

    passwords_ok = true

    if (! user_params[:userPassword].empty? or ! user_params[:userPassword_confirmation].empty?) and user_params[:userPassword_confirmation] == user_params[:userPassword]
      require 'securerandom'

      salt = SecureRandom.urlsafe_base64(12)
      digest = Base64.encode64(Digest::SHA1.digest(user_params[:userPassword] + salt) + salt).chomp
      
      @user.userPassword = '{SSHA}' + digest
    elsif (! user_params[:userPassword].empty? or ! user_params[:userPassword_confirmation].empty?) and user_params[:userPassword_confirmation] != user_params[:userPassword]
      passwords_ok = false
    end

    if ! user_params[:groups].nil?
      user_params[:groups].reject! { | x | x.nil? or x.empty? }

      unless user_params[:groups][0].nil?
        groups = user_params[:groups][0].split(',')

        @user.groups = groups.map! { | group |
          Group.find(group)
        }

        @groups = gid_to_select(@user.groups).to_json
      end
    end

    @domains = Setting.find_by_key("domains").value
    mail_ok = true
    if user_params[:mail].empty? or !@domains.include?(@user.mail.split("@")[1])
      mail_ok = false
    end

    if @user.valid? and passwords_ok and mail_ok
      if @user.save
        if @user.out_of_office == "1"
          %x{ #{Rails.root}/vendor/zarafa-set-oof #{@user.uid} #{@user.out_of_office} "#{@user.out_subject}" "#{file.path}" }
        else
          %x{ #{Rails.root}/vendor/zarafa-set-oof #{@user.uid} #{@user.out_of_office} }
        end
        flash[:success] = "User '#{@user.uid}' was successfully edited."
        File.unlink("#{Dir.tmpdir}/#{@user.uid}_message")
  
        redirect_to users_path and return
      end
    else
      if !passwords_ok
        @user.errors.add(:userPassword, "Passwords don't match.")
        @user.errors.add(:userPassword_confirmation)
      end
      unless mail_ok
        if user_params[:mail].empty?
          @user.errors.add(:mail, "can't be empty")
        else
          @user.errors.add(:domain, "is not in authorized list")
        end
      end
      @messages[:danger] = 'Some fields are in error, unable to save the user'
      @user.mail = @user.mail.split("@")[0]
    end

    users_list = dn_to_uid @user.zarafaSendAsPrivilege(true) unless @user.zarafaSendAsPrivilege.nil?
    @user.zarafaSendAsPrivilege = users_list.to_json

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

  def update_quota
    unless params[:uid].nil?
      user = User.find(params[:uid])
      begin
        quota = Quota.find_by! uid: user.uid
      rescue
        quota = Quota.new(:uid => user.uid)
      end
      quota.value = %x{ zarafa-admin --detail #{user.uid} | grep 'Current store size:' }.split("\t")[1].strip.chomp
      quota.save
      render :text => "#{quota.value}", :layout => false
    end
  end

  private

  def user_params
    params.require(:user).permit(:uid,
                                 :givenName,
                                 :sn,
                                 :mail,
                                 :domain,
                                 :userPassword,
                                 :out_of_office,
                                 :out_message,
                                 :out_subject,
                                 :zarafaAdmin,
                                 :zarafaHidden,
                                 :zarafaQuotaSoft,
                                 :zarafaQuotaHard,
                                 :zarafaSharedStoreOnly,
                                 :userPassword_confirmation,
                                 :zarafaAliases => [],
                                 :zarafaSendAsPrivilege => [],
                                 :groups => [],
    )
  end

  def dn_to_uid data
    data.reject! { | x | x.nil? or x.empty? }

    data.map! { | dn |
      begin
        user = User.find(dn)
      rescue
        user = Group.find(dn)
      end
      if user.is_a? User
        {
          "text" => user.cn,
          "id"   => user.uid
        }
      else
        {
          "text" => user.cn,
          "id" => user.cn
        }
      end
    }
  end

  def uid_to_dn data
    data.reject! { | x | x.nil? or x.empty? }
    
    data = data[0].split(',') unless data.empty?

    data.map! { | uid |
      begin
        privilege_user = User.find(uid)

        'uid=' << privilege_user.uid << ',' << privilege_user.base
      rescue
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

  def add_to_group_all
    group = Group.find(:first, :attribute => "cn", :value => "all");
    group.members << @user

    @user.groups.push group
    @groups = gid_to_select(@user.groups).to_json
  end
end
