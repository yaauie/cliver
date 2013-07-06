# # encoding: utf-8
# require 'cliver'

# describe Cliver::Dependency do
#   let(:mismatch_exception) { Cliver::Dependency::VersionMismatch }
#   let(:missing_exception) { Cliver::Dependency::NotFound }
#   let(:requirements) { ['6.8'] }
#   let(:executable) { 'fubar' }
#   let(:detector) { nil }
#   let(:dependency) do
#     Cliver::Dependency.new(executable, *requirements, &detector)
#   end

#   context 'when dependency found' do
#     before(:each) { dependency.stub(:installed_version) { version } }

#     # sampling of requirements; actual implementation
#     # is supplied by rubygems/requirement and well-tested there.
#     context '~>' do
#       let(:requirements) { ['~> 6.8'] }
#       context 'when version matches exactly' do
#         let(:version) { '6.8' }
#         it 'should not raise' do
#           expect { dependency.assert! }.to_not raise_exception
#         end
#       end
#       context 'when major matches, and minor too low' do
#         let(:version) { '6.7' }
#         it 'should raise' do
#           expect { dependency.assert! }.to raise_exception mismatch_exception
#         end
#       end
#       context 'when major matches, and minor bumped' do
#         let(:version) { '6.13' }
#         it 'should not raise' do
#           expect { dependency.assert! }.to_not raise_exception
#         end
#       end
#       context 'when major too high' do
#         let(:version) { '7.0' }
#         it 'should raise' do
#           expect { dependency.assert! }.to raise_exception mismatch_exception
#         end
#       end
#       context 'patch version present' do
#         let(:version) { '6.8.1' }
#         it 'should not raise' do
#           expect { dependency.assert! }.to_not raise_exception
#         end
#       end
#       context 'pre-release of version that matches' do
#         let(:version) { '6.8.a' }
#         it 'should raise' do
#           expect { dependency.assert! }.to raise_exception mismatch_exception
#         end
#       end
#     end

#     context 'multi [>=,<]' do
#       let(:requirements) { ['>= 1.1.4', '< 3.1'] }
#       context 'matches both' do
#         let(:version)  { '2.0' }
#         it 'should not raise' do
#           expect { dependency.assert! }.to_not raise_exception
#         end
#       end
#       context 'fails one' do
#         let(:version)  { '3.1' }
#         it 'should raise' do
#           expect { dependency.assert! }.to raise_exception mismatch_exception
#         end
#       end
#     end

#     context 'none' do
#       let(:requirements) { [] }
#       let(:version) { '3.1' }
#       it 'should not raise' do
#         expect { dependency.assert! }.to_not raise_exception
#       end
#     end
#   end

#   context 'when dependency not found' do
#     before(:each) { dependency.stub(:installed_version) { nil } }

#     it 'should raise' do
#       expect { dependency.assert! }.to raise_exception missing_exception
#     end
#   end

#   context '#installed_version' do
#     before(:each) do
#       if `which #{executable}`.chomp.empty?
#         pending "#{executable} not installed, test will flap."
#       end
#     end
#     let(:detector_touches) { [] }
#     context 'ruby using filter' do
#       let(:requirement) { '~> 1.2.3p112' }
#       let(:executable) { 'ruby' }
#       let(:filter) { proc { |ver| ver.tr('p', '.') } }
#       let(:detector) { proc { '1.2.3p456' } }
#       let(:dependency) do
#         Cliver::Dependency.new(executable, requirement, :filter => filter,
#                                                         :detector => detector)
#       end
#       let(:installed_version) { dependency.installed_version }
#       subject { installed_version }

#       it { should eq '1.2.3.456' }
#     end
#     context 'ruby with detector-block returned value' do
#       let(:requirements) { ['~> 10.1.4'] }
#       let(:fake_version) { 'ruby 10.1.5' }
#       let(:executable) { 'ruby' }
#       let(:detector) do
#         proc do |ruby|
#           detector_touches << true
#           fake_version
#         end
#       end
#       it 'should succeed' do
#         expect { dependency.assert! }.to_not raise_exception
#       end
#       context 'the detector' do
#         before(:each) { dependency.assert! }
#         it 'should have been touched' do
#           detector_touches.should_not be_empty
#         end
#       end
#       context 'when block-return doesn\'t meet requirements' do
#         let(:fake_version) { '10.1433.32.alpha' }
#         it 'should raise' do
#           expect { dependency.assert! }.to raise_exception mismatch_exception
#         end
#       end
#     end
#     context 'awk with no requirements' do

#       let(:requirements) { [] }
#       let(:executable) { 'awk' }
#       let(:fake_version) { nil }

#       it 'should succeed' do
#         expect { dependency.assert! }.to_not raise_exception
#       end
#       context 'the detector' do
#         before(:each) { dependency.assert! }
#         it 'should not have been touched' do
#           detector_touches.should be_empty
#         end
#       end
#     end
#   end
# end
