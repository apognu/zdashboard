class GroupsController < ApplicationController
  include ApplicationHelper

  def index
    @title = 'Group management'

    page = 0
    page = (params[:page].to_i - 1) if params[:page].present?
    groups_per_page = 5

    @groups = Group.all
    @pages = paginate(groups_per_page, @groups.length, page)
    @groups = @groups.slice(groups_per_page * page, groups_per_page)
  end

  def edit
    @group = Group.find(params[:cn])

    @title = "Edit group #{@group.cn}"
  end

  def update
    @group = Group.find(params[:cn])
    @group.mail = group_params[:mail]

    if ! group_params[:members].nil?
      group_params[:members].reject! { | x | x.nil? or x.empty? }

      @group.members = group_params[:members]
    end

    if @group.valid?
      if @group.save
        flash[:success] = "Group '#{@group.cn}' was successfully edited."
        redirect_to groups_path and return
      end
    end

    render :edit
  end

  private

  def group_params
    params.require(:group).permit(:cn,
                                  :mail,
                                  :members => []
    )
  end
end
