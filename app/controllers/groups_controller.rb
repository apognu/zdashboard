class GroupsController < ApplicationController
  include ApplicationHelper
  include UsersHelper

  def index
    @title = 'Group management'
    @breadcrumbs.concat([ crumbs[:groups] ])

    page = 0
    page = (params[:page].to_i - 1) if params[:page].present?
    groups_per_page = 5

    @groups = Group.all
    @pages = paginate(groups_per_page, @groups.length, page)
    @groups = @groups.slice(groups_per_page * page, groups_per_page)
  end

  def new
    @title = 'Create a new group'
    @breadcrumbs.concat([ crumbs[:groups], 'Create a new group' ])

    @group = Group.new
  end

  def save
    @title = 'Create a new group'

    @group = Group.new(group_params[:cn])
    @group.mail = group_params[:mail]

    if ! group_params[:members].nil?
      group_params[:members].reject! { | x | x.nil? or x.empty? }

      unless group_params[:members][0].nil?
        group_members = group_params[:members][0].split(',')
        @group.members = group_members.map! { | memberuid |
          User.find(memberuid)
        }  

        @group_members = uid_to_select(@group.members).to_json
      else
        @group.members = []
      end
    end

    # What to do with those fuckers?
    @group.gidNumber = get_next_gidnumber 

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

    members_list = uid_to_select @group.members

    @group_members = members_list.to_json

    @title = "Edit group #{@group.cn}"
    @breadcrumbs.concat([ crumbs[:groups], "Edit group #{@group.cn}" ])
  end

  def update
    @group = Group.find(params[:cn])
    @group.mail = group_params[:mail]

    if ! group_params[:members].nil?
      group_params[:members].reject! { | x | x.nil? or x.empty? }

      unless group_params[:members][0].nil?
        group_members = group_params[:members][0].split(',')

        @group.members = group_members.map! { | memberuid |
          User.find(memberuid)
        }

        @group_members = uid_to_select(@group.members).to_json
      else
        @group.members = []
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

  private

  def group_params
    params.require(:group).permit(:cn,
                                  :displayName,
                                  :mail,
                                  :members => []
    )
  end

  def get_next_gidnumber
    groups = Group.find(:all, :attribute => 'gidNumber')

    max = 0
    groups.each do | g |
      if g.gidNumber > max
        max = g.gidNumber
      end
    end
    return max+1
  end

  def crumbs
    {
      :groups   => { :title => 'Groups management', :link => :groups }
    }
  end
end
