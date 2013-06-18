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
    def self.assert!(*args, &block)
      new(*args, &block).assert!
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
    # @options options [Cliver::Detector, #to_proc] :detector
    # @yieldparam [String] full path to executable
    # @yieldreturn [String] Gem::Version-parsable string version
    def initialize(executable, *args, &detector)
      raise ArgumentError, 'executable' unless executable[EXECUTABLE_PATTERN]

      options = args.last.kind_of?(Hash) ? args.pop : {}

      @executable = executable.dup.freeze
      @requirement = Gem::Requirement.new(args) unless args.empty?
      @detector = detector || options.fetch(:detector) { Detector.new }
    end

    # @raise [VersionMismatch] if installed version does not match requirement
    # @raise [DependencyNotFound] if no installed version on your path
    def assert!
      version = installed_version
      raise(DependencyNotFound, "#{@executable} missing.") unless version

      if @requirement && !@requirement.satisfied_by?(Gem::Version.new(version))
        raise VersionMismatch,
              "expected #{@executable} to be #{@requirement}, got #{version}"
      end
    end

    # @private
    # @return [nil]    if no version present
    # @return [String] Gem::Version-parsable string version
    # @return [true]   if present and no requirements (optimization)
    def installed_version
      which, _ = Open3.capture2e("which #{@executable}")
      executable_path = which.chomp
      return nil if executable_path.empty?
      return true unless @requirement

      @detector.to_proc.call(executable_path).tap do |version|
        unless version
          raise ArgumentError,
                "found #{@executable} at '#{executable_path}' " +
                'but could not detect its version.'
        end
      end
    end
  end
end
