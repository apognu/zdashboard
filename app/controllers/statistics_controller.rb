class StatisticsController < ApplicationController

  def index
    @title = "Statistics"

    @disk = get_disk_space

    @license = get_license_information
  
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

  private

  def get_disk_space
    disk_used = %x{ grep "attachment_path" /etc/zarafa/server.cfg }.split("=")[1].strip.chomp

    disk_status = %x{ df #{disk_used} | tail -1 }.split

    disk_status = { "value" => disk_status[2].to_i, "max" => disk_status[1].to_i}
    return disk_status
  end

  def get_license_information
    informations = %x{ zarafa-admin --user-count | head -4 | tail -1 }.split("\t").reject!{|c| c.empty?}
    if informations[1] == "no limit"
      informations[1] = "unlimited"
    end
    informations = { "value" => informations[2].to_i, "max" => informations[1] }

    return informations
  end

end
