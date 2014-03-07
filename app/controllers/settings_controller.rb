class SettingsController < ApplicationController

  def index
    @title = 'Settings management'
    @breadcrumbs.concat([ crumbs[:settings] ])

    @domains = Setting.find_by_key("domains")

    @defaultDomain = Setting.find_by_key("defaultDomain").value

    @defaultQuotaSoft = Setting.find_by_key("defaultQuotaSoft").value
    @defaultQuotaHard = Setting.find_by_key("defaultQuotaHard").value

    @settings = Setting.new
  end

  def save

    success = true

    unless setting_params[:domains].empty?
      begin
        domains = Setting.find_by! key: :domains
      rescue
        domains = Setting.new(:key => :domains)
      end
      domains.value = setting_params[:domains].reject{ |c| c.empty? }
      unless domains.save
        success = false
      end
    end

    unless setting_params[:defaultDomain].empty?
      begin 
        defaultDomain = Setting.find_by! key: :defaultDomain
      rescue
        defaultDomain = Setting.new(:key => :defaultDomain)
      end
      defaultDomain.value = setting_params[:defaultDomain]
      unless defaultDomain.save
        success = false
      end
    end

    unless setting_params[:defaultQuotaSoft].empty?
      begin
        defaultQuotaSoft = Setting.find_by! key: :defaultQuotaSoft
      rescue
        defaultQuotaSoft = Setting.new(:key => :defaultQuotaSoft)
      end
      defaultQuotaSoft.value = setting_params[:defaultQuotaSoft]
      unless defaultQuotaSoft.save
        success = false
      end
    end

    unless setting_params[:defaultQuotaHard].empty?
      begin
        defaultQuotaHard = Setting.find_by! key: :defaultQuotaHard
      rescue
        defaultQuotaHard = Setting.new(:key => :defaultQuotaHard)
      end
      defaultQuotaHard.value = setting_params[:defaultQuotaHard]
      unless defaultQuotaHard.save
        success = false
      end
    end

    if success
      flash[:success] = "Settings was successfully up-to-date"
    else
      flash[:danger] = "An error has occured"
    end
    redirect_to settings_path and return
  end

  private

  def setting_params
    params.require(:setting).permit(:defaultDomain,
                                    :defaultQuotaSoft,
                                    :defaultQuotaHard,
                                    :domains => [],
    )
  end

  def crumbs
    {
      :settings => { :title => 'Settings management', :link => :settings }
    }
  end

end
