require "rails/generators/active_record"

module Rails::Acm
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration
      source_root File.join(__dir__, "templates")

      def copy_templates
        migration_template "migration_template.rb",
          "db/migrate/create_rails_acm_datamodel.rb",
          migration_version: migration_version

        puts "\nAlmost set! Next, run:\n\n    rails db:migrate"
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
