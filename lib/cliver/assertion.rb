# encoding: utf-8
require 'open3'
require 'rubygems/requirement'

module Cliver
  # The core of Cliver, Assertion is responsible for detecting the
  # installed version of a binary and determining if it meets the requirements
  class Assertion

    include Which # platform-specific implementation of `which`

    # An exception class raised when assertion is not met
    DependencyNotMet = Class.new(ArgumentError)

    # An exception that is raised when executable present is the wrong version
    DependencyVersionMismatch = Class.new(DependencyNotMet)

    # An exception that is raised when executable is not present
    DependencyNotFound = Class.new(DependencyNotMet)

    # A pattern for extracting a {Gem::Version}-parsable version
    PARSABLE_GEM_VERSION = /[0-9]+(.[0-9]+){0,4}(.[a-zA-Z0-9]+)?/.freeze

    # @overload initialize(executable, *requirements, options = {})
    # @param executable [String]
    # @param requirements [Array<String>, String] splat of strings
    #   whose elements follow the pattern
    #     [<operator>] <version>
    #   Where <operator> is optional (default '='') and in the set
    #     '=', '!=', '>', '<', '>=', '<=', or '~>'
    #   And <version> is dot-separated integers with optional
    #   alphanumeric pre-release suffix. See also
    #   {http://docs.rubygems.org/read/chapter/16 Specifying Versions}
    # @param options [Hash<Symbol,Object>]
    # @option options [Cliver::Detector, #to_proc] :detector (Detector.new)
    # @yieldparam [String] full path to executable
    # @yieldreturn [String] containing a {Gem::Version}-parsable substring
    def initialize(executable, *args, &detector)
      options = args.last.kind_of?(Hash) ? args.pop : {}

      @executable = executable.dup.freeze
      @requirement = Gem::Requirement.new(args) unless args.empty?
      @detector = detector || options.fetch(:detector) { Detector.new }
    end

    # @raise [DependencyVersionMismatch] if installed version does not match
    # @raise [DependencyNotFound] if no installed version on your path
    def assert!
      version = installed_version
      raise(DependencyNotFound, "'#{@executable}' missing.") unless version

      if @requirement && !@requirement.satisfied_by?(Gem::Version.new(version))
        raise DependencyVersionMismatch,
              "expected '#{@executable}' to be #{@requirement}, got #{version}"
      end
    end

    # Finds the executable on your path using {Cliver::Which};
    # if the executable is present and version requirements are specified,
    # uses the specified detector to get the current version.
    # @private
    # @return [nil]    if no version present
    # @return [String] Gem::Version-parsable string version
    # @return [true]   if present and no requirements (optimization)
    def installed_version
      executable_path = which(@executable)
      return nil unless executable_path
      return true unless @requirement

      version_string = @detector.to_proc.call(executable_path)
      (version_string && version_string[PARSABLE_GEM_VERSION]).tap do |version|
        unless version
          raise ArgumentError,
                "found #{@executable} at '#{executable_path}' " +
                'but could not detect its version.'
        end
      end
    end
  end
end
