environments.each do |env|
  desc "Loads settings specific to #{env}"
  task env do
    unset(:rails_env) # We have to unset because the underlying deploy.rb tries to protect set vars
    set(:rails_env) { env }
    # Load additional configuration from the app_slices dir
    environment_path = fetch(:environment_path, "config/deploy/environments/#{env}.rb")
    load environment_path if File.exists?(environment_path)
  end
end