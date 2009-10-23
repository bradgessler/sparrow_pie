set(:nginx_path)    { '/etc/nginx' }
set(:nginx_spinner) { '/etc/init.d/nginx' }

namespace :nginx do
  [:restart, :stop, :start].each do |t|
    desc "#{t.to_s.capitalize} nginx server."
    task t, :roles => :web do
      sudo "#{nginx_spinner} #{t.to_s}"
    end
  end
  
  namespace :site do
    desc "Present a maintenance page to visitors."
    task :disable, :roles => :web do
      disable_site(nginx_site)
      enable_site(nginx_site_disabled)
      nginx.restart
    end

    desc "Makes the application web-accessible again."
    task :enable, :roles => :web do
      disable_site(nginx_site_disabled)
      enable_site(nginx_site)
      nginx.restart
    end

    # Create a symlink to enable an nginx site
    def enable_site(site)
      link "#{nginx_path}/sites-enabled/#{site}" => "#{nginx_path}/sites-available/#{site}"
    end

    # Create a symlink to disable nginx site
    def disable_site(site)
      run "rm #{nginx_path}/sites-enabled/#{site}"
    end
  end
end