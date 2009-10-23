set(:local_ssh_public_key_path)    { File.expand_path('~/.ssh/id_rsa.pub') }
set(:remote_authorized_keys_path)  { '~/.ssh/authorized_keys' }

namespace :ssh do
  namespace :keys do
    desc "pushes ssh keys to servers"
    task :push do
      # TODO make this stupid thing work
#       run "mkdir ~/.ssh && touch #{remote_authorized_keys_path}"
#       remote_ssh_keys = capture "cat #{remote_authorized_keys_path}"
#       my_public_key = File.read(local_ssh_public_key_path)
# 
# puts remote_ssh_keys
# 
#       # Figure out of the key is already in the file.. skip if its already been pushed
#       unless remote_ssh_keys.include? my_public_key
#         run "echo #{my_public_key} >> #{remote_authorized_keys_path}"
#       else
#         logger.info "You already pushed your key up in here"
#       end
    end
  end
end