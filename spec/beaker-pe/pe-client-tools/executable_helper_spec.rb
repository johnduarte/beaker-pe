require 'spec_helper'
require 'beaker'
require 'scooter'

#{{{
class MockResult
  def initialize(value)
    @value = value
  end
  def stdout
    return @value
  end
end

describe Beaker::DSL::PEClientTools::ExecutableHelper::Private do
  describe "#get_tools_bin_path" do
    context "when Windows" do
      it "returns C:\\ProgramData\\Puppet Labs\\Client\\tools\\bin" do
        platform =  { :platform => Beaker::Platform.new('windows-2012r2-x86_64') }
        host =  Beaker::Host.create('host', platform, make_host_opts('host', platform))
        allow(host).to receive(:exec).and_return(MockResult.new('C:\ProgramData'))
        expect(subject.get_tools_bin_path(host)).to eq('C:\\ProgramData\\Puppet Labs\\Client\\tools\\bin')
      end
    end
    context "when RHEL-7" do
      it "returns /opt/puppetlabs/client-tools/bin" do
        platform =  { :platform => Beaker::Platform.new('el-7-x86_64') }
        host =  Beaker::Host.create('host', platform, make_host_opts('host', platform))
        #allow(host).to receive(:exec).and_return(MockResult.new('C:\ProgramData'))
        expect(subject.get_tools_bin_path(host)).to eq('/opt/puppetlabs/client-tools/bin')
      end
    end
  end
end
#}}}


class MixedWithExecutableHelper
  include Beaker::DSL::PEClientTools::ExecutableHelper
end
  describe MixedWithExecutableHelper do

  let(:method_name)   { "puppet_#{tool}_on"}

  shared_examples 'pe-client-tool' do

    it 'has a method to execute the tool' do
      expect(subject).to respond_to(method_name)
    end
  end

  context 'puppet-code' do
    let(:tool) {'code'}

    it_behaves_like 'pe-client-tool'
    #{{{
      context 'on el-7' do
        it 'has a PATH of /opt/puppetlabs/clienttools' do
          platform =  { :platform => Beaker::Platform.new('el-7-x86_64') }
          host =  Beaker::Host.create('host', platform, make_host_opts('host', platform))
          allow(host).to receive(:exec)
          expect(host).to receive(:build_win_batch_command).never
          expect(Beaker::Command).to receive(:new).with("/opt/puppetlabs/client-tools/bin/puppet-code", [], { :cmdexe => true})
          #expect(subject.send(method_name, host))
          subject.puppet_code_on(host)
        end
      end
    context 'on windows' do
      it 'has a PATH of %PROGRAMFILES%\Puppet Labs\Client tools\bin' do
          platform =  { :platform => Beaker::Platform.new('windows-2012r2-x86_64') }
          host =  Beaker::Host.create('host', platform, make_host_opts('host', platform))
          allow(host).to receive(:exec).and_return(MockResult.new('C:\ProgramData'))
          expect(host).to receive(:build_win_batch_command)
          allow(instance_of(Private)).to receive(:create_remote_file).and_return(0)
          expect(Beaker::Command).to receive(:new).with("echo", ["%PROGRAMFILES%"], {:cmdexe=>true})
          #expect(subject.send(method_name, host))
          subject.puppet_code_on(host)
      end
    end
      #}}}
  end

  context 'puppet-access' do
    let(:tool) {'access'}

    it_behaves_like 'pe-client-tool'
  end

  context 'puppet-job' do
    let(:tool) {'job'}

    it_behaves_like 'pe-client-tool'
  end

  context 'puppet-app' do
    let(:tool) {'app'}

    it_behaves_like 'pe-client-tool'
  end

  context 'puppet-db' do
    let(:tool) {'db'}

    it_behaves_like 'pe-client-tool'
  end

  context 'puppet-query' do
    let(:tool) {'query'}

    it_behaves_like 'pe-client-tool'
  end

  it 'has a method to login with puppet access' do
    expect(subject).to respond_to('login_with_puppet_access_on')
  end

  context 'puppet access login with lifetime parameter' do
    let(:logger) {Beaker::Logger.new}
    let(:test_host) {Beaker::Host.create('my_super_host',
                                         {:roles => ['master', 'agent'],
                                          :platform => 'linux',
                                          :type => 'pe'},
                                          make_opts)}
    let(:username) {'T'}
    let(:password) {'Swift'}
    let(:credentials) {{:login => username, :password => password}}
    let(:test_dispatcher) {Scooter::HttpDispatchers::ConsoleDispatcher.new(test_host, credentials)}

    before do
      allow(logger).to receive(:debug) { true }
      expect(test_dispatcher).to be_kind_of(Scooter::HttpDispatchers::ConsoleDispatcher)
      expect(test_host).to be_kind_of(Beaker::Host)
      expect(test_host).to receive(:exec)
    end

    it 'accepts correct value' do
      expect{subject.login_with_puppet_access_on(test_host, test_dispatcher, {:lifetime => '5d'})}.not_to raise_error
    end
  end
end
