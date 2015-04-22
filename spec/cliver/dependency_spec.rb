require 'cliver'
require 'spec_helper'
require 'fileutils'
require 'tmpdir'

describe Cliver::Dependency do
  let(:executable) { 'foo' }

  before do
    @paths = []

    path = Dir.mktmpdir 'cliver'
    FileUtils.mkdir path + '/foo'
    @paths << path

    path = Dir.mktmpdir 'cliver'
    FileUtils.touch path + '/foo'
    FileUtils.chmod 0755, path + '/foo'
    @paths << path

    @expect = path + '/foo'

    @path = @paths.join File::PATH_SEPARATOR
  end

  after do
    @paths.each do |tmpdir|
      FileUtils.remove_entry_secure tmpdir
    end
  end

  it 'should not detect directory' do
    expect(Cliver::Dependency.new(executable, :path => @path).detect!).to eq @expect
  end
end
