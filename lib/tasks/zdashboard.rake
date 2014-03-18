namespace :zdashboard do
  desc "Initiate required environment for Zarafa Dashboard to run"
  task init: :environment do
    puts
    puts 'Initializing Zarafa Dashboard default environment:'

    begin
      group = Group.find 'all'

      colorize :red, 'group "all" already exists.'
    rescue LDAP::EntryNotFound
      group = Group.new 'all'

      if group.valid?
        if group.save?
          colorize :green, 'group "all" successfully created.'
        end
      end
    end

    colorize :green, 'zdashboard:init completed. :)'
  end

  desc "Update quota db"
  task update_quota: :environment do
    puts
    puts "Updating users' quota ..."
    puts
    users = User.find(:all, :filter => "(!(zarafaResourceType=*))")
    users.each do | u |
      update_db_quota u
      puts "[\033[32mOK\033[0m] #{u.uid}"
    end
    puts
    puts "Update finished"
  end

  private

  def update_db_quota user
    begin
      quota = Quota.find_by! uid: user.uid
    rescue
      quota = Quota.new(:uid => user.uid)
    end
    quota.value = %x{ zarafa-admin --detail #{user.uid} | grep 'Current store size:' }.split("\t")[1].strip.chomp
    quota.save
    return quota.value
  end

  def colorize(color, text)
    colors = {
      :black    => 30,
      :red      => 31,
      :green    => 32,
      :yellow   => 33,
      :blue     => 34,
      :magenta  => 35,
      :cyan     => 36,
      :white    => 37
    }

    puts "      \033[#{colors[color]}m->\033[0m #{text}"
  end

end
