# encoding: utf-8

# Core-Extensions on File
class File
  # determine whether a String path is absolute.
  # @example
  #   File.absolute_path?('foo') #=> false
  #   File.absolute_path?('/foo') #=> true
  #   File.absolute_path?('foo/bar') #=> false
  #   File.absolute_path?('/foo/bar') #=> true
  #   File.absolute_path?('C:foo/bar') #=> false
  #   File.absolute_path?('C:/foo/bar') #=> true
  # @param path [String] - a pathname
  # @return [Boolean]
  def self.absolute_path?(path)
    false | path[ABSOLUTE_PATH_PATTERN]
  end

  unless defined?(POSIX_ABSOLUTE_PATH_PATTERN)
    POSIX_ABSOLUTE_PATH_PATTERN = /\A\//.freeze
  end

  unless defined?(WINDOWS_ABSOLUTE_PATH_PATTERN)
    WINDOWS_ABSOLUTE_PATH_PATTERN = Regexp.union(
      POSIX_ABSOLUTE_PATH_PATTERN,
      /\A([A-Z]:)?(\\|\/)/i
    ).freeze
  end

  ABSOLUTE_PATH_PATTERN = begin
    File::ALT_SEPARATOR ?
      WINDOWS_ABSOLUTE_PATH_PATTERN :
      POSIX_ABSOLUTE_PATH_PATTERN
  end unless defined?(ABSOLUTE_PATH_PATTERN)
end
