task :defaults do
  set_default :user,            'deployer'
  set_default :group,           user
  set_default :port,            '22'
  set_default :ssh_options,     '-t'
  set_default :forward_agent,   true
  set_default :term_mode,       :nil
  set_default :rails_env,       'staging'
  set_default :shared_paths,    ['tmp', 'log', 'public/uploads', 'config/database.yml']
  set_default :branch,          'staging'
  set_default :deploy_to,       "/home/#{user}/#{application}/#{deploy_server}"

  set_default :sockets_path,    "#{deploy_to}/#{shared_path}/tmp/sockets"
  set_default :pids_path,       "#{deploy_to}/#{shared_path}/tmp/pids"
  set_default :logs_path,       "#{deploy_to}/#{shared_path}/log"
  set_default :templates_path,  "lib/mina/templates"
  set_default :config_path,     "#{deploy_to}/#{shared_path}/config"

  set_default :unicorn_socket,  "#{sockets_path}/unicorn.sock"
  set_default :unicorn_pid,     "#{pids_path}/unicorn.pid"
  set_default :unicorn_config,  "#{config_path}/unicorn.rb"
  set_default :unicorn_workers, 1
  set_default :unicorn_log,     "#{logs_path}/unicorn.log"
  set_default :unicorn_user,    user
  set_default :unicorn_script,  "/etc/init.d/unicorn_#{application}_#{deploy_server}"

  set_default :nginx_config,    "#{nginx_path}/sites-enabled/#{application}_#{deploy_server}"
  set_default :nginx_log_path,  "#{deploy_to}/#{shared_path}/log/nginx"
  set_default :nginx_server_name, domain || server_ip

  set_default :postgresql_host, "localhost"
  set_default :postgresql_user, application
  set_default :postgresql_database, "#{application}_#{deploy_server}"
  set_default :postgresql_pid,  "/var/run/postgresql/9.1-main.pid"
end