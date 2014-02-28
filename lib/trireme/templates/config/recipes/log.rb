namespace :log do
  desc "View log tail"
  task :tail, roles: :app do
    run "tail #{shared_path}/log/#{rails_env}.log -n 50"
  end
end