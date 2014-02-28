namespace :logrotate do
  desc "Setup logrotate for all log files in log directory"
  task :setup, roles: :app do
    template "logrotate.erb", "/tmp/logrotate"
    run "#{sudo} mv /tmp/logrotate /etc/logrotate.d/#{application}_#{stage}"
  end
  after "deploy:setup", "logrotate:setup"
end