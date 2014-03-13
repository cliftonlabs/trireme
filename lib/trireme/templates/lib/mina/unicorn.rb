namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"
  task :setup do
    queue 'echo "-----> Creating unicorn configuration file"'
    queue "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", unicorn_config

    queue 'echo "-----> Creating unicorn init script"'
    template "unicorn_init.erb", unicorn_script, :tee, :sudo
    queue echo_cmd "sudo chmod +x #{unicorn_script}"
    queue echo_cmd "sudo update-rc.d -f unicorn_#{application}_#{deploy_server} defaults"
  end

  %w[start stop restart].each do |command|
    desc "#{command.capitalize} unicorn"
    task command do
      queue %{echo "-----> #{command.capitalize} Unicorn"}
      queue echo_cmd "/etc/init.d/unicorn_#{application}_#{deploy_server} #{command}"
    end
  end
end