task :setup do
  invoke :create_extra_paths
  invoke :'postgresql:setup'
  invoke :'nginx:setup'
  invoke :'unicorn:setup'
  invoke :'logrotate:setup'
end

task :echo_config do
  queue %{echo #{rails_env}}
  queue %{echo #{deploy_to}}
  queue %{echo #{shared_path}}
  queue %{echo #{shared_paths.first}}
end

task :create_extra_paths do
  queue 'echo "-----> Create configs path"'
  queue echo_cmd "mkdir -p #{config_path}"

  queue 'echo "-----> Create shared paths"'
  shared_dirs = shared_paths.map { |file| "#{deploy_to}/#{shared_path}/#{file}" }.uniq
  cmds = shared_dirs.map do |dir|
    queue echo_cmd %{mkdir -p "#{dir}"}
  end

  queue 'echo "-----> Create PID and Sockets paths"'
  cmds = [pids_path, sockets_path].map do |path|
    queue echo_cmd %{mkdir -p #{path}}
  end
end

def template(from, to, *opts)
  queue %{echo "-----> Creating file at #{to} using template #{from}"}
  if opts.include? :tee
    command = ''
    command << 'sudo ' if opts.include? :sudo
    command << %{tee #{to} <<'zzENDOFFILEzz' > /dev/null\n}
    command << %{#{erb("#{templates_path}/#{from}")}}
    command << %{\nzzENDOFFILEzz}
  else
    command = %{echo '#{erb("#{templates_path}/#{from}")}' > #{to}}
  end
  queue echo_cmd command
end