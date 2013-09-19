# encoding: utf-8
require 'cliver'

describe Cliver::ShellCapture do
  subject { Cliver::ShellCapture.new('./spec/support/test_command') }

  its(:stdout) { should eq '1.1.1' }
  its(:stderr) { should eq 'foo baar 1' }
  its(:command_found) { should be_true }

  context 'looking for a command that does not exist' do
    subject { Cliver::ShellCapture.new('./spec/support/test_command_not_here') }

    its(:stdout) { should eq '' }
    its(:stderr) { should eq '' }
    its(:command_found) { should be_false }
  end
end
