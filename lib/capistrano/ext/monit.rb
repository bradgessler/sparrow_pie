monit_bin           = fetch(:monit_bin, '/usr/local/bin/monit')
monitrc_path        = fetch(:monitrc_path, '/etc/monitrc')
monit_cluster_path  = fetch(:monit_cluster_dir, '/etc/monit/cluster')

namespace :monit do
  namespace :all do
    %w[start stop restart monitor unmonitor].each do |command|
      desc "#{command.capitalize} all monit services"
      task command, :roles => [:app, :db] do
        sudo "#{monit_bin} #{command} all"
      end
    end
  end
  
  namespace :group do
    %w[start stop restart monitor unmonitor].each do |command|
      desc "#{command.capitalize} #{application} monit services"
      task command, :roles => [:app, :db] do
        sudo "#{monit_bin} #{command} -g #{application}"
      end
    end
  end
  
  desc "Reinitalize Monit"
  task :reload do
    sudo "#{monit_bin} reload"
  end
  
  desc "Kill monit daemon process monit"
  task :quit do
    sudo "#{monit_bin} quit"
  end
  
  desc "Start monit daemon process"
  task :start do
    sudo monit_bin
  end
  
  # desc "Print full status information for each service"
  # task :status
  # 
  # desc "Print short status information for each service"
  # task :summary
  # 
  # desc "Check all services and start if not running"
  # task :validate
end