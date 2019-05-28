# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'

module Noticent
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)
      desc 'Add OptIn database migrations'
      def self.next_migration_number(path)
        next_migration_number = current_migration_number(path) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      def copy_migrations
        migration_template 'create_optins.rb',
                           'db/migrate/create_optins.rb'
      end
    end
  end
end
