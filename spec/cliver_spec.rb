# encoding: utf-8
require 'cliver'

describe Cliver do
  it { should respond_to :assert }

  it { should respond_to :dependency_unmet? }
  context '#dependency_unmet?' do
    let(:requirements) { [] }
    let(:detector) { proc { } }
    subject { Cliver.dependency_unmet?(executable, *requirements, &detector) }
    context 'when dependency is met' do
      let(:executable) { 'ruby' }
      it { should be_false }
    end
    context 'when dependency is present, but wrong version' do
      let(:executable) { 'ruby' }
      let(:requirements) { ['~> 0.1.0'] }
      let(:detector) { proc { RUBY_VERSION.sub('p', '.') } }
      it { should_not be_false }
      it { should match 'Dependency Version Mismatch:' }
      it { should match "expected 'ruby' to be #{requirements}" }
    end
    context 'when dependency is not present' do
      let(:executable) { 'ruxxxby' }
      it { should_not be_false }
      it { should match 'Dependency Not Found:' }
      it { should match "'#{executable}' missing" }
    end
  end
end
