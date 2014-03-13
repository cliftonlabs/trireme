require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

module Trireme
  class AppGenerator < Rails::Generators::AppGenerator
    class_option :config_file, type: :string, aliases: '-c', desc: "Include yaml configuration file"

    def finish_template
      invoke :trireme_customization
      super
    end

    def trireme_customization
      if options[:config_file]
        say "Loading yaml configuration from #{options[:config_file]}"
        Trireme::configure_with(options[:config_file])
      end
      invoke :configure_generators
      invoke :add_gems
      invoke :remove_routes_comment_lines
      invoke :add_home_controller
      invoke :setup_staging_environment
      if config[:action_mailer] && config[:action_mailer][:smtp_settings]
        invoke :configure_smtp
      end
      invoke :setup_console
      invoke :setup_stylesheets
      invoke :setup_gems
      invoke :create_views_and_layouts
      invoke :setup_deployment
      invoke :setup_git
    end

    def configure_generators
      say 'Configuring generators'

      # Add generator configuration to config/application.rb
      build :configure_generators
    end

    def add_gems
      say 'Adding gems and installing'

      # Remove sqlite gem from Gemfile (we'll add it back under development group)
      build :remove_sqlite_gem

      # Append 'templates/additional_gems' to Gemfile
      build :add_custom_gems

      # Confirm other gems before adding (e.g., Carrierwave)
      build :add_additional_gems

      bundle_command 'install'
    end

    def remove_routes_comment_lines
      # Remove commented lines from config/routes.rb
      # build :remove_routes_comment_lines
    end

    def add_home_controller
      say 'Creating home controller with index'

      build :generate_home_controller
    end

    def setup_staging_environment
      say 'Setting up the staging environment'

      # Create config/environments/staging.rb based on production.rb
      build :setup_staging_environment
    end

    def configure_smtp
      say 'Configuring action mailer for production'

      build :setup_smtp
    end

    def setup_console
      say 'Configuring console (config/initializers/jazz_hands.rb)'

      # Add jazz_hands configuration in config/initializers/jazz_hands.rb
      build :setup_console
    end

    def setup_stylesheets
      say 'Setting up stylesheets'

      # Add boostrap_and_overrides to app/assets/stylesheets; it contains bootstrap variables and imports bootstrap
      build :add_bootstrap_and_overrides

      # Replaces application.css with application.css.scss that imports compass, bootstrap, font-awesome
      build :replace_application_css

      # build :add_foundation_scaffold_templates
    end

    def setup_gems
      say 'Setting up gems...'
      # Add quiet assets config to development (makes it easy to turn off)
      build :setup_quiet_assets

      # Add mailcatcher configuration for development
      build :setup_mailcatcher

      # Sets sublime text as editor for better_errors
      build :set_sublime_text_as_editor

      # Set up devise in accordance with preferences
      build :setup_devise

      # Setup rspec (rspec:install)
      build :setup_rspec

      # Setup guard by copying Guardfile
      build :setup_guard

      # Add configuration for exception notification if it is specified
      if config.has_key? :exception_notification
        build :setup_exception_notification
      end
    end

    def create_views_and_layouts
      say 'Creating partials and adding layouts'

      # Create app/views/shared directory
      build :create_shared_views_directory

      # Copy partials to app/views/shared
      build :create_flashes_partial
      build :create_form_errors_partial
      build :create_admin_actions_partial

      # Add title, icon, placeholder helpers
      build :copy_utility_helper

      build :copy_application_layout

      build :copy_bootstrap_scaffold_templates
    end

    def setup_deployment
      # Get domain and server ip from input
      build :get_server_options

      # Add deploy configuration and recipes
      build :setup_deploy
    end

    def setup_git
      say 'Setting up .gitignore and git repo'

      # Add gitignore_additions to .gitignore
      build :add_to_gitignore

      # Initialize git repository and create first commit
      build :initialize_git
    end

    def outro
      say "Ready to set sail (and probably catch on fire, sink, and kill everyone on board)! Run 'cap deploy:setup' to finish preparing the server for deployment."
    end

    protected

    def get_builder_class
      Trireme::AppBuilder
    end

    def config
      @config ||= Trireme::config
    end
  end
end
