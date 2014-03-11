class StatisticsController < ApplicationController

  def index
    @title = "Statistics"

  end

  def export_csv
    users = User.find(:all, :filter => "(&(!(zarafaResourceType=*)))")

    require 'csv'

    content = CSV.generate do |csv|
      csv << ["uid",
              "last name",
              "first name",
              "quota soft",
              "quota hard",
              "current quota",
              "archive",
              "hidden from address book",
              "admin"
             ]
      users.each do |u|
        begin
          u.current_quota = Quota.find_by_uid!(u.uid).value
        rescue
          u.current_quota = "N.C."
        end
        csv << [u.uid,
                u.sn,
                u.givenName,
                u.zarafaQuotaSoft,
                u.zarafaQuotaHard,
                u.current_quota,
                u.zarafaSharedStoreOnly,
                u.zarafaHidden,
                u.zarafaAdmin
               ]
      end
    end
    
    send_data content, :filename => Time.new.strftime("%Y%m%d%H%M%S") + "_export_users.csv"
  end

end
