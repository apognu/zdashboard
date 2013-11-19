class ZDashboardController < ApplicationController
  def index
    @title = 'Zarafa Dashboard'
  end

  def error_404
    @title = 'Page not found'
    @breadcrumbs.concat([ 'Page not found' ])
    @messages[:danger] = 'We are sorry but an error occured.'

    render :status => 404
  end
end
