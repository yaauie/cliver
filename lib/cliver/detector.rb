# encoding: utf-8
require 'shellwords'

module Cliver
  # The interface for Cliver::Detector classes.
  # @see Cliver::Detector::Default for reference implementation
  module Detector
    # Forward to default implementation
    def self.new(*args, &block)
      Default.new(*args, &block)
    end

    # @param executable [String] the executable to test
    # @return [Array<String>]
    def version_command(executable)
      raise NotImplementedError unless defined? super
      super
    end

    # @return [Regexp] - the pattern used against the output
    #                    of the #version_command, which should
    #                    typically be Gem::Version-parsable.
    def version_pattern
      raise NotImplementedError unless defined? super
      super
    end

    # @param executable [String] - the path to the executable to test
    # @return [String] - should be Gem::Version-parsable.
    def detect_version(executable)
      output = `#{version_command(executable).shelljoin} 2>&1`
      ver = output.scan(version_pattern)
      ver && ver.first
    end

    # This is the interface that any detector must have.
    # @see #detect_version for the returned proc's method signature.
    # @return [Proc]
    def to_proc
      method(:detect_version).to_proc
    end
  end
end
