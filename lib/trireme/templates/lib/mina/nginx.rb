namespace :nginx do
  desc "Setup nginx configuration for this application"
  task :setup do
    queue 'echo "-----> Creating nginx config"'
    template "nginx_unicorn.erb", "/etc/nginx/sites-enabled/#{application}_#{deploy_server}", :tee, :sudo
    queue 'echo "-----> Deleting nginx default site"' if verbose_mode?
    queue echo_cmd "sudo rm -f /etc/nginx/sites-enabled/default"
    invoke :'nginx:restart'
  end

  task :remove do
    queue 'echo "-----> Deleting nginx config"'
    queue "sudo rm -f /etc/nginx/sites-enabled/#{application}_#{deploy_server}"
    invoke :'nginx:restart'
  end

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command do
      queue echo_cmd "sudo service nginx #{command}"
    end
  end
end