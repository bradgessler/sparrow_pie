require 'erb'
require 'yaml'

set(:host_config_path)  { "config/deploy/environments/#{rails_env}/hosts.yml" }
set(:etc_hosts)         { "/etc/hosts" }

namespace :hosts do
  desc "Generates a host file"
  task :configure do
    slices = YAML.load(File.open(host_config_path))
    auto_gen_tags = /\#\s<autogenerated>\n(.+)\#\s<\/autogenerated>/xm
    
    host_file = capture("cat #{etc_hosts}")
    host_entries = %{
    # <autogenerated>
    #{
      slices.map do |slices, config|
        if private_interface = config['private']
          "#{private_interface['ip']}\t#{private_interface['host']}"
        end
      end.join("\n")
    }
    # </autogenerated>}
    
    if host_file =~ auto_gen_tags
      # Replace anything inside of the autogen tags
      host_file.sub(auto_gen_tags, host_entries)
    else
      # Append the autogen tags
      host_file = host_file + host_entries
    end
    
    puts host_file
    
  end
end

def sudo_put(path)
  on_rollback { run "rm -rf #{release_path}" }
  put 
end