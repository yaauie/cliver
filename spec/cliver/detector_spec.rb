# encoding: utf-8
require 'cliver'

describe Cliver::Detector do
  let(:detector) { Cliver::Detector.new(*args) }
  let(:defaults) do
    {
      :version_pattern => Cliver::Detector::DEFAULT_VERSION_PATTERN,
      :command_arg =>     Cliver::Detector::DEFAULT_COMMAND_ARG,
    }
  end
  let(:args) { [] }
  subject { detector }

  it { should respond_to :to_proc }

  its(:command_arg) { should eq defaults[:command_arg] }
  its(:version_pattern) { should eq defaults[:version_pattern] }

  context 'with one string argument' do
    let(:version_arg) { '--release-version' }
    let(:args) { [version_arg] }

    its(:command_arg) { should eq version_arg }
    its(:version_pattern) { should eq defaults[:version_pattern] }
  end

  context 'with one regexp argument' do
    let(:regexp_arg) { /.*/ }
    let(:args) { [regexp_arg] }

    its(:command_arg) { should eq defaults[:command_arg] }
    its(:version_pattern) { should eq regexp_arg }
  end

  context 'with both arguments' do
    let(:version_arg) { '--release-version' }
    let(:regexp_arg) { /.*/ }
    let(:args) { [version_arg, regexp_arg] }

    its(:command_arg) { should eq version_arg }
    its(:version_pattern) { should eq regexp_arg }
  end
end
