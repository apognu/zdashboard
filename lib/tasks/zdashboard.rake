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

  private

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
