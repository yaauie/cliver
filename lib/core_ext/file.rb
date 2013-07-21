# encoding: utf-8

class File
  # determine whether a String path is absolute.
  # @example
  #   File.absolute_path?('foo') #=> false
  #   File.absolute_path?('/foo') #=> true
  #   File.absolute_path?('foo/bar') #=> false
  #   File.absolute_path?('/foo/bar') #=> true
  #   File.absolute_path?('C:foo/bar') #=> false
  #   File.absolute_path?('C:/foo/bar') #=> true
  # @param [String] - a pathname
  # @return [Boolean]
  def self.absolute_path?(path)
    false | File.dirname(path)[/\A([A-Z]:)?#{Regexp.escape(File::SEPARATOR)}/i]
  end
end
