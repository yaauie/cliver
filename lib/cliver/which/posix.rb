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
        which, _, _ = Open3.capture3('which', executable)
        executable_path = which.chomp
        return nil if executable_path.empty?
        executable_path
      rescue Errno::ENOENT
        raise '"which" must be on your path to use Cliver on this system.'
      end
    end
  end
end
