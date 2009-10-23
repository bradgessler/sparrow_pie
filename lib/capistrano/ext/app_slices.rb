app_slices.each do |app_slice|
  desc "[internal] Loads settings specific to #{app_slice}"
  task "_#{app_slice}" do
    unset(:application) # We have to unset because the underlying deploy.rb tries to protect set vars
    set(:application) { app_slice }
    # Load additional configuration from the app_slices dir
    app_slice_path = fetch(:app_slice_path, "config/deploy/app_slices/#{app_slice}.rb")
    load app_slice_path if File.exists?(app_slice_path)
  end
end

app_slices.each do |app_slice|
  namespace app_slice do
    environments.each do |env|
      desc "Loads variables for the `#{env}` environment"
      task env do
        find_and_execute_task env
        find_and_execute_task "_#{app_slice}"
      end
    end
  end
end