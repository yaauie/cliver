# encoding: utf-8
require 'cliver/assertion'

describe Cliver::Assertion do
  let(:mismatch_exception) { Cliver::Assertion::VersionMismatch }
  let(:missing_exception) { Cliver::Assertion::DependencyNotFound }
  let(:requirements) { ['6.8'] }
  let(:executable) { 'fubar' }
  let(:assertion) { Cliver::Assertion.new(executable, *requirements) }

  context 'when dependency found' do
    before(:each) { assertion.stub(:installed_version) { version } }

    # sampling of requirements; actual implementation
    # is supplied by rubygems/requirement and well-tested there.
    context '~>' do
      let(:requirements) { ['~> 6.8'] }
      context 'when version matches exactly' do
        let(:version) { Gem::Version.new('6.8') }
        it 'should not raise' do
          expect { assertion.assert! }.to_not raise_exception
        end
      end
      context 'when major matches, and minor too low' do
        let(:version) { Gem::Version.new('6.7') }
        it 'should raise' do
          expect { assertion.assert! }.to raise_exception mismatch_exception
        end
      end
      context 'when major matches, and minor bumped' do
        let(:version) { Gem::Version.new('6.13') }
        it 'should not raise' do
          expect { assertion.assert! }.to_not raise_exception
        end
      end
      context 'when major too high' do
        let(:version) { Gem::Version.new('7.0') }
        it 'should raise' do
          expect { assertion.assert! }.to raise_exception mismatch_exception
        end
      end
      context 'patch version present' do
        let(:version) { Gem::Version.new('6.8.1') }
        it 'should not raise' do
          expect { assertion.assert! }.to_not raise_exception
        end
      end
      context 'pre-release of version that matches' do
        let(:version) { Gem::Version.new('6.8.a') }
        it 'should raise' do
          version.should be_prerelease
          expect { assertion.assert! }.to raise_exception mismatch_exception
        end
      end
    end

    context 'multi [>=,<]' do
      let(:requirements) { ['>= 1.1.4', '< 3.1'] }
      context 'matches both' do
        let(:version)  { Gem::Version.new('2.0') }
        it 'should not raise' do
          expect { assertion.assert! }.to_not raise_exception
        end
      end
      context 'fails one' do
        let(:version)  { Gem::Version.new('3.1') }
        it 'should raise' do
          expect { assertion.assert! }.to raise_exception mismatch_exception
        end
      end
    end
  end

  context 'when dependency not found' do
    before(:each) { assertion.stub(:installed_version) { nil } }

    it 'should raise' do
      expect { assertion.assert! }.to raise_exception missing_exception
    end
  end
end
