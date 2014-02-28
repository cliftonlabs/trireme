set :domain_name, "demo.#{domain_base}"
set :rewrite_www, false
set :include_ssl, false
set :unicorn_workers, 1
set :default_host, false

set :rails_env, "staging"
set :branch, "staging"