# encoding: utf-8

require 'open3'

module Cliver
  module Which
    # Posix implementation of Which
    # Required and mixed into Cliver::Which in posix environments
    module Posix
      # @param executable [String]
      # @return [nil,String] - path to found executable
      def which(executable)
        # command -v is the POSIX-specified implementation behind which.
        # http://pubs.opengroup.org/onlinepubs/009695299/utilities/command.html
        which, status = Open3.capture2e('command', '-v', executable)
        return nil unless status.success?
        which.chomp
      end
    end
  end
end
