# encoding: utf-8

module Cliver
  # The `which` command we love on many posix-systems needs analogues on other
  # systems. The Which module congitionally includes the correct implementation
  # into itself, so you can include it into something else.
  module Which
    case RbConfig::CONFIG['host_os']
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      require 'cliver/which/windows'
      include Cliver::Which::Windows
    else
      require 'cliver/which/posix'
      include Cliver::Which::Posix
    end
  end
end
