# encoding: utf-8
require 'open3'

module Cliver
  # Default implementation of Cliver::Detector
  # Requires a command argument (default '--version')
  # and a pattern-matcher Regexp with sensible default.
  class Detector::Default < Struct.new(:command_arg, :version_pattern)
    include Detector

    DEFAULT_VERSION_PATTERN = /(?<=version )[0-9][.0-9a-z]+/i.freeze
    DEFAULT_COMMAND_ARG = '--version'.freeze

    # Forgiving input, allows either argument if only one supplied.
    #
    # @overload initialize(command_arg)
    # @overload initialize(version_pattern)
    # @overload initialize(command_arg, version_pattern)
    # @param command_arg [String] ('--version')
    # @param version_pattern [Regexp] (/(?<=version )[0-9][.0-9a-z]+/i)
    def initialize(*args)
      command_arg = args.shift if args.first.kind_of?(String)
      version_pattern = args.shift
      super(command_arg, version_pattern)
    end

    def version_pattern
      super || DEFAULT_VERSION_PATTERN
    end

    def command_arg
      super || DEFAULT_COMMAND_ARG
    end

    def version_command(executable)
      [executable, command_arg]
    end
  end
end
