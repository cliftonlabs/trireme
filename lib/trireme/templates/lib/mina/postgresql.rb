require 'highline/import'

namespace :postgresql do
  desc "Generate the database.yml configuration file"
  task :setup do
    get_postgresql_password
    invoke :'postgresql:create_user'
    invoke :'postgresql:create_database'
    template "postgresql.yml.erb", "#{config_path}/database.yml"
  end

  desc "Create a user for this application."
  task :create_user do
    get_postgresql_password
    queue %{sudo -u postgres psql -c "create user \\"#{postgresql_user}\\" with password '#{postgresql_password}';"; true}
  end

  desc "Create a database for this application."
  task :create_database do
    queue %Q{sudo -u postgres psql -c "create database \\"#{postgresql_database}\\" owner \\"#{postgresql_user}\\";"; true}
  end

  desc "Symlink the database.yml file into latest release"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "postgresql:symlink"
end

def get_postgresql_password
  if !postgresql_password
    pw = ask "Postgresql password: " do |p|
      p.echo = '*'
    end
    set :postgresql_password, pw
  end
end