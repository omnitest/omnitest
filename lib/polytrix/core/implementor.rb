require 'hashie/dash'
require 'hashie/extensions/coercion'

module Polytrix
  class FeatureNotImplementedError < StandardError
    def initialize(feature)
      super "Feature #{feature} is not implemented"
    end
  end
  class Implementor < Hashie::Dash
    include Polytrix::Logger
    include Polytrix::Core::FileSystemHelper
    include Hashie::Extensions::Coercion
    include Polytrix::Runners::Executor
    property :name
    property :basedir, required: true
    property :language
    coerce_key :basedir, Pathname

    def initialize(data)
      data = Hashie::Mash.new data
      data[:name] ||= File.basename data[:basedir]
      data[:basedir] = File.absolute_path(data[:basedir])
      super(data)
    end

    def bootstrap
      execute('./scripts/bootstrap', cwd: basedir, prefix: name)
    rescue Errno::ENOENT
      logger.warn "Skipping bootstrapping for #{name}, no script/bootstrap exists"
    end

    def build_challenge(challenge_data)
      challenge_data[:source_file] ||= find_file basedir, challenge_data[:name]
      challenge_data[:basedir] ||= basedir
      challenge_data[:source_file] = relativize(challenge_data[:source_file], challenge_data[:basedir])
      challenge_data[:implementor] ||= self
      challenge_data[:suite] ||= ''
      fail FeatureNotImplementedError, "#{name} is not setup" unless File.directory? challenge_data[:basedir]
      Challenge.new challenge_data
    rescue Polytrix::Core::FileSystemHelper::FileNotFound
      raise FeatureNotImplementedError, challenge_data[:name]
    end
  end
end
