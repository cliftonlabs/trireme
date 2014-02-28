module Trireme
  class AppBuilder < Rails::AppBuilder
    attr_accessor :domain_base, :server_ip

    include Trireme::Actions

    def add_additional_gems
      if yes? "Add carrierwave for file uploading?"
        @generator.gem 'carrierwave'
        @generator.gem 'mini_magick'
      end
    end

    def add_bootstrap_and_overrides
      copy_file "app/assets/stylesheets/_bootstrap_and_overrides.scss"
    end

    def add_custom_gems
      gems_path = find_in_source_paths 'additional_gems'
      new_gems = File.open(gems_path).read
      append_file 'Gemfile', "\n#{new_gems}"
    end

    def add_to_gitignore
      gitignore_file = find_in_source_paths('gitignore_additions')
      gitignore = File.open(gitignore_file).read
      append_file '.gitignore', gitignore
    end

    def configure_generators
      generators_config = <<-RUBY.gsub(/^   {2}/, '')
        config.generators do |generate|
          generate.helper      false
          generate.assets      false
          generate.view_specs  false
          generate.stylesheets false
          generate.javascripts false
        end\n
      RUBY
      inject_into_class 'config/application.rb', 'Application', generators_config
    end

    def configure_rspec
      generate 'rspec:install'
      run 'rm test/ -Rf'
    end

    def copy_utility_helper
      copy_file "app/helpers/utility_helper.rb", force: true
    end

    def copy_application_layout
      copy_file "app/views/layouts/application.html.erb", force: true
    end

    def copy_bootstrap_scaffold_templates
      directory 'lib/templates/erb/scaffold'
    end

    def create_flashes_partial
      copy_file "app/views/shared/_flashes.html.erb"
    end

    def create_admin_actions_partial
      copy_file "app/views/shared/_admin_actions.html.erb"
    end

    def create_form_errors_partial
      copy_file "app/views/shared/_form_errors.html.erb"
    end

    def create_shared_views_directory
      empty_directory 'app/views/shared'
    end

    def generate_home_controller
      generate :controller, "home index"
      route "root to: 'home\#index'"
    end

    def get_server_options
      @domain_base ||= ask("Domain:")
      if !@domain_base.blank? && config_settings.has_key?(:chef) && yes?("Get IP from Chef (#{config_settings[:chef][:url]})?")
        require 'open-uri'
        begin
          @server_ip = open("#{config_settings[:chef][:url]}#{@domain_base}").base_uri.to_s.match(/http:\/\/([\d\.]+)/)[1]
          puts "Setting server ip to #{@server_ip}"
        rescue
          puts "Failed to get ip"
        end
      end
      @domain_base = "example.com" if @domain_base.blank?
      @server_ip ||= ask("Server IP (if you have one):")
    end

    def initialize_git
      git :init
      git add: "."
      git commit: "-m 'Inital commit'"
    end

    # Overrides generation of rails readme file
    def readme
      template "README.md.erb", "README.md"
    end

    def remove_routes_comment_lines
      replace_in_file 'config/routes.rb', /Application\.routes\.draw do.*end/m, "Application.routes.draw do\nend"
    end

    def remove_sqlite_gem
      gsub_file 'Gemfile', /^\s*gem .sqlite3.+$/, ''
    end

    def replace_application_css
      remove_file 'app/assets/stylesheets/application.css'
      copy_file 'app/assets/stylesheets/application.css.scss'
    end

    def set_sublime_text_as_editor
      copy_file "config/initializers/better_errors.rb"
    end

    def setup_smtp
      configure_environment "production",
        "config.action_mailer_delivery_method = :smtp\n\tconfig.action_mailer.smtp_settings = #{format_config(config_settings[:action_mailer][:smtp_settings])}"
    end

    def setup_capistrano
      if @domain_base && @server_ip
        opts = { domain_base: @domain_base, server_ip: @server_ip, force: true }
      else
        opts[:domain_base] = ask("Domain:")
        opts[:server_ip] = ask("Server IP:")
        opts[:force] = true
      end
      template "config/deploy.rb.erb", "config/deploy.rb", opts
      directory "config/deploy"
      copy_file "Capfile", "Capfile"
      directory "config/recipes"
    end

    def setup_console
      copy_file "config/initializers/jazz_hands.rb"
    end

    def setup_devise
      if config_settings[:devise][:include] || yes?("Add Devise?")
        devise_model = ask("Devise model (default: #{config_settings[:devise][:model]}):").underscore
        devise_model = config_settings[:devise][:model] if devise_model.blank?
        @generator.gem 'devise'
        run 'bundle install'
        generate 'devise:install'
        generate "devise #{devise_model}"
        generate "devise:views"
        bundle_command 'exec rake db:migrate'
        if config_settings[:devise][:seed] || yes?("Seed database with #{devise_model}@example.com?")
          append_file 'db/seeds.rb', "devise_user = #{devise_model.titleize}.create email: '#{devise_model}@example.com', password: 'password'"
          bundle_command 'exec rake db:seed'
        end
      end
    end

    def setup_exception_notification
      en_config = "config.middleware.insert_before Warden::Manager, ExceptionNotification::Rack,\n"
      if config_settings[:exception_notification][:email]
        config_settings[:exception_notification][:email][:email_prefix] = "[#{app_name.titleize} Exception]"
        en_config << "\t\t:email => #{format_config(config_settings[:exception_notification][:email], 2)}"
      end
      if config_settings[:exception_notification][:irc]
        config_settings[:exception_notification][:irc][:prefix] = "[#{app_name.titleize} Production]"
        en_config << ",\n\t\t" if en_config[/}\Z/]
        en_config << ":irc => #{format_config(config_settings[:exception_notification][:irc], 2)}"
      end
      configure_environment "production", en_config
    end

    def setup_guard
      copy_file "Guardfile"
    end

    def setup_mailcatcher
      configure_environment "development",
        "config.action_mailer.delivery_method = :smtp\n  config.action_mailer.smtp_settings = { :address => \"localhost\", :port => 1025 }"
    end

    def setup_quiet_assets
      configure_environment "development",
        "config.quiet_assets = true"
    end

    def setup_staging_environment
      run 'cp config/environments/production.rb config/environments/staging.rb'
    end

    # ----------

    def config_settings
      @config ||= Trireme::config
    end

    def format_config(yml, num_tabs = 1)
      tabs = "\t" * (num_tabs + 1)
      yml.to_s.gsub(/\A{/, "{\n#{tabs}").gsub(/, :/, ",\n#{tabs}:").gsub(/}\Z/, "\n#{"\t" * num_tabs}}").gsub("=>", " => ")
    end
  end
end