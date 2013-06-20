# encoding: utf-8
require 'cliver/version'
require 'cliver/which'
require 'cliver/assertion'
require 'cliver/detector'
require 'cliver/detector/default'

module Cliver
  # @see Cliver::Assertion
  # @overload (see Cliver::Assertion#initialize)
  # @param (see Cliver::Assertion#initialize)
  # @raise (see Cliver::Assertion#assert!)
  # @return (see Cliver::Assertion#assert!)
  def self.assert(*args, &block)
    Assertion.new(*args, &block).assert!
  end

  extend self

  # Wraps Cliver::assert and returns truthy/false instead of raising
  # @see Cliver::assert
  # @return [False,String] either returns false or the reason why the
  #                        assertion was unmet.
  def dependency_unmet?(*args, &block)
    Cliver.assert(*args, &block)
    false
  rescue Assertion::DependencyNotMet => error
    # Cliver::Assertion::VersionMismatch -> 'Version Mismatch'
    reason = error.class.name.split('::').last.gsub(/(?<!\A)[A-Z]/, ' \\0')
    "#{reason}: #{error.message}"
  end
end
