require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'new_relic/recipes'

set :stages, ["staging", "production"]
set :default_stage, "staging"

set :application, "Hedra Site"

set :scm, :git
set :repository,  "git@github.com:hedra-digital/hedra-site.git"
set :deploy_to, "/home/deploy/apps/staging"
set :deploy_via, 'copy'
set :user, 'deploy'

ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "livrodaclasse_rsa")]

set :use_sudo, false
set :keep_releases, 3

default_run_options[:pty] = true

role :web, "hedra.com.br"
role :app, "hedra.com.br"
role :db,  "hedra.com.br", :primary => true

task :uname do
  run "uname -a"
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

after 'deploy:update_code', 'deploy:symlink_db', 'deploy:symlink_uploads', 'deploy:copy_old_sitemap'
after 'deploy:update', 'deploy:cleanup'
# We need to run this after our collector mongrels are up and running
# This goes out even if the deploy fails, sadly
after "deploy:update", "newrelic:notice_deployment"

namespace :deploy do
  desc "Symlinks the database.yml"
  task :symlink_db, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end
end

namespace :deploy do
  desc "Symlinks the uploads directory"
  task :symlink_uploads, :roles => :app do
    run "ln -nfs #{deploy_to}/shared/public/uploads #{release_path}/public/uploads"
  end
end

namespace :deploy do
  task :copy_old_sitemap do
    run "if [ -e #{previous_release}/public/sitemap_index.xml.gz ]; then cp #{previous_release}/public/sitemap* #{current_release}/public/; fi"
  end
end

namespace :deploy do
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

# namespace :deploy do
#   namespace :assets do
#     desc "Precompile assets on local machine and upload them to the server."
#     task :precompile, :roles => :web, :except => { :no_release => true } do
#       run_locally "bundle exec rake assets:precompile"
#       find_servers_for_task(current_task).each do |server|
#         run_locally "rsync -vr --exclude='.DS_Store' public/assets #{user}@#{server.host}:#{shared_path}/"
#       end
#     end
#   end
# end

desc "Run the super-awesome rake task"
task :super_awesome do
  rake = fetch(:rake, 'rake')
  rails_env = fetch(:rails_env, 'production')

  run "cd '#{current_path}' && #{rake} super_awesome RAILS_ENV=#{rails_env}"
end
