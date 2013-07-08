# encoding: utf-8
require 'cliver/version'
require 'cliver/dependency'
require 'cliver/detector'
require 'cliver/filter'

# Cliver is tool for making dependency assertions against
# command-line executables.
module Cliver

  # The primary interface for the Cliver gem allows detection of an executable
  # on your path that matches a version requirement, or raise an appropriate
  # exception to make resolution simple and straight-forward.
  # @see Cliver::Dependency
  # @overload (see Cliver::Dependency#initialize)
  # @param (see Cliver::Dependency#initialize)
  # @raise (see Cliver::Dependency#detect!)
  # @return (see Cliver::Dependency#detect!)
  def self.detect!(*args, &block)
    Dependency::new(*args, &block).detect!
  end

  # A non-raising variant of {::detect!}, simply returns false if dependency
  # cannot be found.
  # @see Cliver::Dependency
  # @overload (see Cliver::Dependency#initialize)
  # @param (see Cliver::Dependency#initialize)
  # @raise (see Cliver::Dependency#detect)
  # @return (see Cliver::Dependency#detect)
  def self.detect(*args, &block)
    Dependency::new(*args, &block).detect
  end

  # A legacy interface for {::detect} with the option `strict: true`, ensures
  # that the first executable on your path matches the requirements.
  # @see Cliver::Dependency
  # @overload (see Cliver::Dependency#initialize)
  # @param (see Cliver::Dependency#initialize)
  # @option options [Boolean] :strict (true) @see Cliver::Dependency::initialize
  # @raise (see Cliver::Dependency#assert!)
  # @return (see Cliver::Dependency#assert!)
  def self.assert(*args, &block)
    options = args.last.kind_of?(Hash) ? args.pop : {}
    args << options.merge(:strict => true)
    Dependency::new(*args, &block).detect!
  end

  extend self

  # Wraps Cliver::assert and returns truthy/false instead of raising
  # @see Cliver::assert
  # @overload (see Cliver::Assertion#initialize)
  # @param (see Cliver::Assertion#initialize)
  # @return [False,String] either returns false or the reason why the
  #                        assertion was unmet.
  def dependency_unmet?(*args, &block)
    Cliver.assert(*args, &block)
    false
  rescue Dependency::NotMet => error
    # Cliver::Assertion::VersionMismatch -> 'Version Mismatch'
    reason = error.class.name.split(':').last.gsub(/([a-z])([A-Z])/, '\\1 \\2')
    "#{reason}: #{error.message}"
  end
end
