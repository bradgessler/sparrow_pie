# Tails the log file
namespace :tail do
  desc "Tails the rails log"
  task :rails, :roles => :app  do
    stream "tail -f #{shared_path}/log/#{rails_env}.log"
  end
  
  [:crow, :thin, :alloy].each do |log|
    desc "Tails the rails #{log}"
    task log, :roles => :app  do
      stream "tail -f #{shared_path}/log/#{log}.log"
    end
  end
end