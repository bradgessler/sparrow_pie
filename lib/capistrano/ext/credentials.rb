require 'erb'

set(:credentials_config) { ERB.new(File.read('config/deploy/templates/credentials.yml.erb')).result(binding) }

after "deploy:setup", "credentials:config"
after "deploy:update_code", "credentials:symlink"

namespace :credentials do
  desc "Configures a credentials.yml file"
  task :config, :roles => [:app] do
  end
  
  desc "Create database yaml in shared path" 
  task :config, :roles => [:app]  do
    sudo "mkdir -p #{shared_path}/config" 
    put fetch(:credentials_config), "#{shared_path}/config/credentials.yml" 
  end
      
  desc "Symlinks credentials into config dir"
  task :symlink, :roles => [:app, :db] do
    link "#{release_path}/app_slices/#{application}/config/credentials.yml" => "#{shared_path}/config/credentials.yml"
  end
end