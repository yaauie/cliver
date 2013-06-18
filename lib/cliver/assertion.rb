# encoding: utf-8
require 'open3'
require 'rubygems/requirement'

module Cliver
  # The core of Cliver, Assertion is responsible for detecting the
  # installed version of a binary and determining if it meets the requirements
  class Assertion
    VersionMismatch = Class.new(ArgumentError)
    DependencyNotFound = Class.new(ArgumentError)

    EXECUTABLE_PATTERN = /\A[a-z][a-zA-Z0-9\-_]*\z/.freeze

    # Creates a new instance with the args and calls #assert.
    # @see #assert
    def self.assert!(*args)
      new(*args).assert!
    end

    # @overload initialize(executable, *requirements, options = {})
    # @param executable [String]
    # @param requirements [Array<String>, String] splat of strings
    #   whose elements follow the pattern
    #     [<operator>] <version>
    #   Where <operator> is optional (default '='') and in the set
    #     '=', '!=', '>', '<', '>=', '<=', or '~>'
    #   And <version> is dot-separated integers with optional
    #   alphanumeric pre-release suffix
    #   @see Gem::Requirement::new
    # @param options [Hash<Symbol,Object>]
    # @options options [#match] :version_matcher
    # @options options [String] :version_arg
    def initialize(executable, *args)
      options = args.last.kind_of?(Hash) ? args.pop : {}
      raise ArgumentError, 'executable' unless executable[EXECUTABLE_PATTERN]

      @executable = executable.dup.freeze
      @requirement = Gem::Requirement.new(args)
      @version_arg = options.fetch(:version_arg, '--version')
      @version_matcher = options.fetch(:version_matcher,
                                       /version ([0-9][.0-9a-z]+)/)
    end

    # @raise [VersionMismatch] if installed version does not match requirement
    # @raise [DependencyNotFound] if no installed version on your path
    def assert!
      version = installed_version
      version || raise(DependencyNotFound, "#{@executable} missing.")
      unless @requirement.satisfied_by?(version)
        raise VersionMismatch,
              "got #{version}, expected #{@requirement}"
      end
    end

    # @private
    def installed_version
      command = "which #{@executable} && #{@executable} #{@version_arg}"
      command_out, _ = Open3.capture2e(command)
      match = @version_matcher.match(command_out)
      match && Gem::Version.new(match[1])
    end
  end
end
