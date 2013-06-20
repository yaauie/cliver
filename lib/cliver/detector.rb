# encoding: utf-8
require 'shellwords'

module Cliver
  # The interface for Cliver::Detector classes.
  # @see Cliver::Detector::Default for reference implementation
  module Detector
    # Forward to default implementation
    # @see Cliver::Detector::Default
    # @overload (see Cliver::Detector::Default#initialize)
    # @param (see Cliver::Detector::Default#initialize)
    # @raise (see Cliver::Detector::Default#initialize)
    # @return (see Cliver::Detector::Default#initialize)
    def self.new(*args, &block)
      Default.new(*args, &block)
    end

    # @param executable_path [String] the executable to test
    # @return [Array<String>]
    def version_command(executable_path)
      raise NotImplementedError
    end

    # @return [Regexp] - the pattern used against the output
    #                    of the #version_command, which should
    #                    contain a {Gem::Version}-parsable substring.
    def version_pattern
      raise NotImplementedError unless defined? super
      super
    end

    # @param executable_path [String] - the path to the executable to test
    # @return [String] - should be contain {Gem::Version}-parsable
    #                    version number.
    def detect_version(executable_path)
      output = `#{version_command(executable_path).shelljoin} 2>&1`
      output[version_pattern]
    end

    # This is the interface that any detector must have.
    # If not overridden, returns a proc that wraps #detect_version
    # @see #detect_version
    # @return [Proc] following method signature of {#detect_version}
    def to_proc
      method(:detect_version).to_proc
    end
  end
end
