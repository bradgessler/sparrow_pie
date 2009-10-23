require 'erb'

set(:backup_path) { "#{shared_path}/backup" }           # Remote folder for the backup paths
set(:upload_path) { File.join(Dir.pwd, 'uploads') }     # Folder THIS machine that will catch uploads from the remote server

# -- Database
set(:db_name)       { Capistrano::CLI.ui.ask("Database name")       {|q| q.default = "#{application}_#{rails_env}"} }
set(:db_host)       { Capistrano::CLI.ui.ask("Database host")       {|q| q.default = "localhost"} }
set(:db_port)       { Capistrano::CLI.ui.ask("Database port")       {|q| q.default = "60000"} }
set(:db_username)   { Capistrano::CLI.ui.ask("Database username")   {|q| q.default = "polleverywhere"} }
set(:db_socket)     { Capistrano::CLI.ui.ask("Database socket") }
set(:db_password)   { Capistrano::CLI.password_prompt("Database Password: ") }
set(:db_config) { ERB.new(File.read('config/deploy/templates/database.yml.erb')).result(binding) }

set(:db_backup_filename)               { "#{ENV['RELEASE'] || fetch(:rails_env)}_sql_dump_#{ENV['RELEASE'] || fetch(:release_name)}.sql" }
set(:db_remote_backup_path)            { File.join(backup_path, fetch(:db_backup_filename))}
set(:db_remote_compressed_backup_path) { "#{fetch(:db_remote_backup_path)}.gz" }
set(:db_local_backup_path)             { fetch(:upload_path) }
set(:db_local_compressed_backup_path)  { File.join(fetch(:db_local_backup_path), "#{fetch(:db_backup_filename)}.gz") }

# Cap task chains
after "deploy:setup", "db:config"
after "deploy:update_code", "db:symlink"

# Internal task chains
before  "db:pull", "db:backup"
before  "db:restart", "db:decompress"
after   "db:backup", "db:compress"

# Tasks for backing up our databases remotely and downloading the dumped files
namespace :db do
  desc "Backup remote database and store on primary server."
  task :backup, :roles => :db, :only => { :primary => true } do
    run "mysqldump --user=#{db_username} --password=#{db_password} --host=#{db_host} #{db_name} > #{fetch(:db_remote_backup_path)}"
  end
  
  desc "Compresses the sql dump file"
  task :compress, :roles => :db, :only => { :primary => true } do
    run "gzip -v #{fetch(:db_remote_backup_path)}"
  end
  
  desc "Decompresses the sql dump file"
  task :decompress, :roles => :db, :only => { :primary => true } do
    run "gzip -dv #{fetch(:db_remote_compressed_backup_path)}"
  end
  
  desc "Backup and download remote database from primary server."
  task :pull, :roles => :db, :only => { :primary => true } do
    get fetch(:db_remote_compressed_backup_path), fetch(:db_local_compressed_backup_path) 
  end
  
  desc "Upload local database dump and store on primary server. Specify RELEASE and SOURCE_ENV. (ex: cap deploy RELEASE=20080717040909 SOURCE_ENV=production)"
  task :push, :roles => :db, :only => { :primary => true } do
    require_env_variables :release, :source_env
    
    upload fetch(:db_local_compressed_backup_path), fetch(:db_remote_compressed_backup_path), :via => :scp
  end
  
  desc "Drop the database"
  task :drop do
    disable_in :production # Too fuckin hot for prod
    rake_task('db:drop')
  end
  
  desc "Create the database"
  task :create do
    disable_in :production # Too fuckin hot for prod
    rake_task('db:create')
  end
  
  task :reset do
    disable_in :production # Too fuckin hot for prod
    drop
    create
  end
  
  desc "Upload local database dump and to primary server and restore."
  task :restore, :roles => :db, :only => { :primary => true } do
    disable_in :production
    # There should DEF be an "ARE YOU FUCKING SURE" prompt here, warn the user that
    # all data will be destroyed
    raise "Not Implemented"
    # Restrict this for production
  end
  
  desc "Create database yaml in shared path" 
  task :config, :roles => [:app, :db]  do
    run "mkdir -p #{shared_path}/config" 
    put fetch(:db_config), "#{shared_path}/config/database.yml" 
  end
  
  # symlink the database.yml file into the current/config directory
  desc "Links the shared files (configuration, etc.) to the current directory."
  task :symlink, :roles => [:app ,:db] do
    # Make rails shut up when rake tasks are being run...
    link "#{release_path}/config/database.yml" => "#{shared_path}/config/database.yml"
    link "#{release_path}/app_slices/#{application}/config/database.yml" => "#{shared_path}/config/database.yml"
  end
end