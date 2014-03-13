namespace :logrotate do
  desc "Setup logrotate for all log files in log directory"
  task :setup do
    template "logrotate.erb", "/etc/logrotate.d/#{application}_#{stage}", :tee, :sudo
  end
  after "deploy:setup", "logrotate:setup"
end