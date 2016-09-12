require 'spec_helper'

class MixedWithConfigFileHelper
  include Beaker::DSL::PEClientTools::ConfigFileHelper
end

class MockResult
  def initialize(value)
    @value = value
  end
  def stdout
    return @value
  end
end

describe MixedWithConfigFileHelper do
  describe "#write_client_tool_config_on" do

    it 'has a method to write a config file' do
      expect(subject.respond_to?('write_client_tool_config_on')).not_to be(false)
    end

    context 'on el-7' do
      it 'creates file in /etc' do
        platform =  { :platform => Beaker::Platform.new('el-7-x86_64') }
        host =  Beaker::Host.create('host', platform, make_host_opts('host', platform))
        allow(host).to receive(:exec)

        expect(subject).to receive(:create_remote_file).with(host,/^\/etc/, 'some file content')
        subject.write_client_tool_config_on(host, 'global', 'code', 'some file content')
      end
    end
    context 'on windows' do
      it 'creates file in C:\programdata' do
        platform =  { :platform => Beaker::Platform.new('windows-2012r2-x86_64') }
        host =  Beaker::Host.create('host', platform, make_host_opts('host', platform))
        allow(host).to receive(:exec).and_return(MockResult.new('C:\ProgramData'))

        expect(subject).to receive(:create_remote_file).with(host,/ProgramData/i, 'some file content')
        subject.write_client_tool_config_on(host, 'global', 'code', 'some file content')
      end
    end
  end
end
