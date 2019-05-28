# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'

module Noticent
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)
      desc 'Generate Noticent required files'
      def self.next_migration_number(path)
        next_migration_number = current_migration_number(path) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      def copy_migrations
        migration_template 'create_opt_ins.rb',
                           'db/migrate/create_opt_ins.rb'

        puts 'DB migration generated. Run rake db:migrate next'
      end

      def copy_initializer 
        template 'noticent_initializer.rb', 'config/initializers/noticent.rb'

        puts 'Install Complete!'
      end

      def copy_model
        template 'opt_in.rb', 'app/models/opt_in.rb'
      end
    end
  end
end
