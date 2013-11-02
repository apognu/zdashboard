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
end
