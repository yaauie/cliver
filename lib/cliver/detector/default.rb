# encoding: utf-8
require 'open3'

module Cliver
  # Default implementation of Cliver::Detector
  # Requires a command argument (default '--version')
  # and a pattern-matcher Regexp with sensible default.
  class Detector::Default < Struct.new(:command_arg, :version_pattern)
    include Detector

    # Default pattern to use when searching {#version_command} output
    DEFAULT_VERSION_PATTERN = /version [0-9][.0-9a-z]+/i.freeze

    # Default command argument to use against the executable to get
    # version output
    DEFAULT_COMMAND_ARG = '--version'.freeze

    # Forgiving input, allows either argument if only one supplied.
    #
    # @overload initialize(command_arg)
    # @overload initialize(version_pattern)
    # @overload initialize(command_arg, version_pattern)
    # @param command_arg [String]
    # @param version_pattern [Regexp]
    def initialize(*args)
      command_arg = args.shift if args.first.kind_of?(String)
      version_pattern = args.shift
      super(command_arg, version_pattern)
    end

    # The pattern to match the version in {#version_command}'s output.
    # Defaults to {DEFAULT_VERSION_PATTERN}
    # @overload (see Cliver::Detector#version_pattern)
    # @return (see Cliver::Detector#version_pattern)
    def version_pattern
      super || DEFAULT_VERSION_PATTERN
    end

    # The argument to pass to the executable to get current version
    # Defaults to {DEFAULT_COMMAND_ARG}
    # @return [String]
    def command_arg
      super || DEFAULT_COMMAND_ARG
    end

    # @overload (see Cliver::Detector#version_command)
    # @return (see Cliver::Detector#version_command)
    def version_command(executable_path)
      [executable_path, command_arg]
    end
  end
end
