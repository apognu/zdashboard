class GroupsController < ApplicationController
  include ApplicationHelper
  include UsersHelper

  def index
    @title = 'Group management'
    @breadcrumbs.concat([ crumbs[:groups] ])

    if request.post?
      params[:search].gsub!("(", "\\(")
      params[:search].gsub!(")", "\\)")
      @groups = Group.find(:all, :filter => "(&(cn=*#{params[:search]}*))")
      render :partial => "groups", :layout => false
    end
  end

  def new
    @title = 'Create a new group'
    @breadcrumbs.concat([ crumbs[:groups], 'Create a new group' ])

    @group = Group.new
  end

  def save
    @title = 'Create a new group'

    @group = Group.new(sanitize_dn(group_params[:cn]))
    @group.mail = group_params[:mail]
    @group.members = []
    @group.zarafaHidden = group_params[:zarafaHidden]

    if ! group_params[:members].nil?
      group_params[:members].reject! { | x | x.nil? or x.empty? }

      unless group_params[:members][0].nil?
        members = group_params[:members][0].split(',')

        @group.members = members.map { | uid |
          uid = uid.split(":")
          if uid[0] == "u"
            User.find(uid[1])
          elsif uid[0] == "c"
            Contact.find(uid[1])
          elsif uid[0] == "g"
            Group.find(uid[1])
          end
        }

       @members = uid_to_select(@group.members).to_json
      end
    end

    # What to do with those fuckers?
    @group.gidNumber = next_gidnumber

    if @group.valid?
      if @group.save
        flash[:success] = "Group '#{@group.cn}' was successfully created."

        redirect_to groups_path and return
      end
    else
      @messages[:danger] = 'Some fields are in error, unable to save the group.'
    end

    render :new
  end

  def edit
    @group = Group.find(params[:cn])

    retrieve_members @group
    members = uid_to_select @group.members

    @members = members.to_json

    @title = "Edit group #{@group.cn}"
    @breadcrumbs.concat([ crumbs[:groups], "Edit group #{@group.cn}" ])
  end

  def update
    @group = Group.find(params[:cn])
    @group.mail = group_params[:mail]
    @group.members = []
    @group.memberUid = []
    @group.zarafaHidden = group_params[:zarafaHidden]

    if ! group_params[:members].nil?
      group_params[:members].reject! { | x | x.nil? or x.empty? }

      unless group_params[:members][0].nil?
        members = group_params[:members][0].split(',')

        @group.members = members.map { | uid |
          uid = uid.split(":")
          if uid[0] == "u"
            User.find(uid[1])
          elsif uid[0] == "c"
            Contact.find(uid[1])
          elsif uid[0] == "g"
            Group.find(uid[1])
          end
        }

        @members = uid_to_select(@group.members).to_json
      end
    end

    if @group.valid?
      if @group.save
        flash[:success] = "Group '#{@group.cn}' was successfully edited."

        redirect_to groups_path and return
      end
    else
      @messages[:danger] = 'Some fields are in error, unable to save the group.'
    end

    render :edit
  end

  def delete
    group = Group.find(params[:cn])

    if group.destroy
      flash[:success] = "Group '#{group.cn}' was successfully deleted."

      redirect_to groups_path
    end
  end

  def list
    groups = Group.find(:all, :filter => "(&(|(gidNumber=*#{params[:q]}*)(cn=*#{params[:q]}*)(mail=*#{params[:q]}*@*))(!(zarafaResourceType=*)))")

    groups.map! do | group |
      {
        'text' => group.cn,
        'id' => group.cn
      }
    end
    render :json => groups
  end

  private

  def group_params
    params.require(:group).permit(:cn,
                                  :displayName,
                                  :mail,
                                  :zarafaHidden,
                                  :members => []
    )
  end

  def next_gidnumber
    groups = Group.find(:all, :attribute => 'gidNumber')

    groups.max_by { | group | group.gidNumber }.gidNumber + 1
  end

  def crumbs
    {
      :groups   => { :title => 'Groups management', :link => :groups }
    }
  end

  def retrieve_members group
    group.members.clear

    group.memberUid(true).each { |uid|
      tmp = User.find(:first, :value => uid)
      if tmp.nil?
        tmp = Contact.find(:first, :value => uid)
      end
      if tmp.nil?
        tmp = Group.find(:first, :value => uid)
      end
      unless tmp.nil?
        group.members.push tmp
      end
    }
  end

end
