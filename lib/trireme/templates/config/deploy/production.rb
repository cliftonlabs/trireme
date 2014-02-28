# Domain name for nginx config
set :domain_name, domain_base

# Remove www from incoming requests
set :rewrite_www, true

# Include ssl information for nginx
set :include_ssl, false

# Default, requires setting server_ip
set :default_host, true
set :server_ip, "#{server_ip}"

set :unicorn_workers, 1

set :rails_env, "production"
set :branch, "master"