# frozen_string_literal: true

require "spec_helper"
require "generator_spec"
require "generator_spec/test_case"

module Noticent
  module Generators
    describe InstallGenerator, type: :generator do
      include GeneratorSpec::TestCase

      root_dir = File.expand_path("../../../../../tmp", __dir__)
      destination root_dir

      before :all do
        prepare_destination
        run_generator
      end

      it "creates the installation db migration and initializer" do
        migration_file =
          Dir.glob("#{root_dir}/db/migrate/*create_opt_ins.rb")

        assert_file migration_file[0],
                    /class CreateOptIns < ActiveRecord::Migration/

        initializer_file = Dir.glob("#{root_dir}/config/initializers/noticent.rb")
        assert_file initializer_file[0],
                    /Noticent.configure do |config|/

        model_file = Dir.glob("#{root_dir}/app/models/opt_in.rb")
        assert_file model_file[0],
                    /class OptIn < ActiveRecord::Base/
      end
    end
  end
end
