# encoding: utf-8
require 'rubygems/requirement'

module Cliver
  # This is how a dependency is specified.
  class Dependency

    # An exception class raised when assertion is not met
    NotMet = Class.new(ArgumentError)

    # An exception that is raised when executable present, but
    # no version that matches the requirements is present.
    VersionMismatch = Class.new(Dependency::NotMet)

    # An exception that is raised when executable is not present at all.
    NotFound = Class.new(Dependency::NotMet)

    # A pattern for extracting a {Gem::Version}-parsable version
    PARSABLE_GEM_VERSION = /[0-9]+(.[0-9]+){0,4}(.[a-zA-Z0-9]+)?/.freeze

    # @overload initialize(executables, *requirements, options = {})
    #   @param executables [String,Array<String>] api-compatible executable names
    #                                      e.g, ['python2','python']
    #   @param requirements [Array<String>, String] splat of strings
    #     whose elements follow the pattern
    #       [<operator>] <version>
    #     Where <operator> is optional (default '='') and in the set
    #       '=', '!=', '>', '<', '>=', '<=', or '~>'
    #     And <version> is dot-separated integers with optional
    #     alphanumeric pre-release suffix. See also
    #     {http://docs.rubygems.org/read/chapter/16 Specifying Versions}
    #   @param options [Hash<Symbol,Object>]
    #   @option options [Cliver::Detector] :detector (Detector.new)
    #   @option options [#to_proc, Object] :detector (see Detector::generate)
    #   @option options [#to_proc] :filter ({Cliver::Filter::IDENTITY})
    #   @option options [Boolean]  :strict (false)
    #                                      true -  fail if first match on path fails
    #                                              to meet version requirements.
    #                                              This is used for Cliver::assert.
    #                                      false - continue looking on path until a
    #                                              sufficient version is found.
    #   @option options [String]   :path   ('*') the path on which to search
    #                                      for executables. If an asterisk (`*`) is
    #                                      included in the supplied string, it is
    #                                      replaced with `ENV['PATH']`
    #
    #   @yieldparam executable_path [String] (see Detector#detect_version)
    #   @yieldreturn [String] containing a version that, once filtered, can be
    #                         used for comparrison.
    def initialize(executables, *args, &detector)
      options = args.last.kind_of?(Hash) ? args.pop : {}
      @detector = Detector::generate(detector || options[:detector])
      @filter = options.fetch(:filter, Filter::IDENTITY).extend(Filter)
      @path = options.fetch(:path, '*').sub('*', ENV['PATH'])
      @strict = options.fetch(:strict, false)

      @executables = Array(executables).dup.freeze

      @requirement = args unless args.empty?
    end

    # Get all the installed versions of the api-compatible executables.
    # If a block is given, it yields once per found executable, lazily.
    # @yieldparam executable_path [String]
    # @yieldparam version [String]
    # @return [Hash<String,String>] executable_path, version
    def installed_versions
      return enum_for(:installed_versions) unless block_given?
      @executables.each_with_object({}) do |executable, memo|
        find_executables(executable).each do |executable_path|
          version = detect_version(executable_path)
          memo[executable_path] = version

          break(2) if yield(executable_path, version)
        end
      end
    end

    # The non-raise variant of {#detect!}
    # @return (see #detect!)
    #   or nil if no match found.
    def detect
      detect!
    rescue Dependency::NotMet
      nil
    end

    # Detects an installed version of the executable that matches the
    # requirements.
    # @return [String] path to an executable that meets the requirements
    # @raise [Cliver::Dependency::NotMet] if no match found
    def detect!
      installed = installed_versions.each do |path, version|
        return path if requirement_satisfied_by?(version)
        strict?
      end

      # dependency not met. raise the appropriate error.
      raise_not_found! if installed.empty?
      raise_version_mismatch!(installed)
    end

    private

    # @api private
    # @return [Gem::Requirement]
    def filtered_requirement
      @filtered_requirement ||= begin
        Gem::Requirement.new(@filter.requirements(@requirement))
      end
    end

    # @api private
    # @param raw_version [String]
    # @return [Boolean]
    def requirement_satisfied_by?(raw_version)
      return true unless @requirement
      parsable_version = @filter.apply(raw_version)[PARSABLE_GEM_VERSION]
      parsable_version || raise(ArgumentError) # TODO: make descriptive
      filtered_requirement.satisfied_by? Gem::Version.new(parsable_version)
    end

    # @api private
    # @raise [Cliver::Dependency::NotFound] with appropriate error message
    def raise_not_found!
      raise Dependency::NotFound.new <<-EOERR
        Could not find an executable #{@executables} on your path.
      EOERR
    end

    # @api private
    # @raise [Cliver::Dependency::VersionMismatch] with appropriate error message
    # @param installed [Hash<String,String>] the found versions
    def raise_version_mismatch!(installed)
      raise Dependency::VersionMismatch.new <<-EOERR
        Could not find an executable #{executable_description} that matched the
        requirements #{requirements_description}.
        Found versions were #{installed.inspect}
      EOERR
    end

    # @api private
    # @return [String] a plain-language representation of the executables
    #   for which we were searching
    def executable_description
      quoted_exes = @executables.map {|exe| "'#{exe}'" }
      return quoted_exes.first if quoted_exes.size == 1

      last_quoted_exec = quoted_exes.pop
      "#{quoted_exes.join(', ')} or #{last_quoted_exec}"
    end

    # @api private
    # @return [String] a plain-language representation of the requirements
    def requirements_description
      @requirement.map {|req| "'#{req}'" }.join(', ')
    end

    # If strict? is true, only attempt the first matching executable on the path
    # @api private
    # @return [Boolean]
    def strict?
      false | @strict
    end

    # Given a path to an executable, detect its version
    # @api private
    # @param executable_path [String]
    # @return [String]
    # @raise [ArgumentError] if version cannot be detected.
    def detect_version(executable_path)
      # No need to shell out if we are only checking its presence.
      return '99.version_detection_not_required' unless @requirement

      raw_version = @detector.to_proc.call(executable_path)
      raw_version || raise(ArgumentError,
                           "The detector #{@detector} failed to detect the" +
                           "version of the executable at '#{executable_path}'")
    end

    # Windows support
    # @api private
    def exts
      ENV.has_key?('PATHEXT') ? ENV.fetch('PATHEXT').split(';') : ['']
    end

    # Analog of Windows `where` command, or a `which` that finds *all*
    # matching executables on the supplied path.
    # @param cmd [String] - the command to find
    # @return [Enumerable<String>] - the executables found, lazily.
    def find_executables(cmd)
      return enum_for(:find_executables, cmd) unless block_given?

      @path.split(File::PATH_SEPARATOR).product(exts).map do |path, ext|
        exe = File.join(path, "#{cmd}#{ext}")
        yield exe if File.executable?(exe)
      end
    end
  end
end