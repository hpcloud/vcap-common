# Copyright (c) 2009-2011 VMware, Inc.
require 'yaml'

require 'vcap/common'
require 'vcap/json_schema'

module VCAP
  class Config
    class << self
      attr_reader :schema

      def define_schema(&blk)
        @schema = VCAP::JsonSchema.build(&blk)
      end

      def from_file(filename, symbolize_keys=true)
        config = YAML.load_file(filename)
        @schema.validate(config)
        config = VCAP.symbolize_keys(config) if symbolize_keys
        config
      end

      def from_doozer(component_id, symbolize_keys=true)
        require 'kato/config'
        config = Kato::Config.get(component_id)
        @schema.validate(config)
        config = config.symbolize_keys if symbolize_keys
        [config, 0]
      end

      def to_file(config, out_filename)
        @schema.validate(config)
        File.open(out_filename, 'w+') do |f|
          YAML.dump(config, f)
        end
      end
    end

  end
end
