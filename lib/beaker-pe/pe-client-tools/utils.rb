module Beaker
  module DSL
    module PEClientTools
      module Utils

        def get_tools_config_path(config_level='global')
          puppetlabs_dir = 'puppetlabs'
          puppetlabs_dir.prepend('.') if config_level == 'user'
          client_tools_path_array = [puppetlabs_dir, 'client-tools']
          case config_level

            when /global/
              base_path = global_base_path(host)
            when /user/
              base_path = home_dir(host)
            else
              raise ArgumentError.new("Unknown config level #{config_level}")
          end
          client_tools_dir = client_tools_path_array.unshift(base_path).join(path_separator(host))
        end

        def get_tools_bin_path(host)
          if host.platform =~ /win/
            basepath = host.exec(Beaker::Command.new('echo', ['%PROGRAMFILES%'], :cmdexe => true)).stdout.chomp
            path = [ basepath, 'Puppet Labs', 'Client', 'tools', 'bin' ].join(path_separator(host))
          else
            basepath = '/opt'
            path = [ basepath, 'puppetlabs', 'client-tools', 'bin' ].join(path_separator(host))
          end
          return path
        end

        def global_config_base_path(host)

          (host.platform =~ /win/) ?host.exec(Beaker::Command.new('echo', ['%PROGRAMDATA%'], :cmdexe => true)).stdout.chomp : '/etc//'
        end

        def path_separator(host)

          (host.platform =~ /win/) ? '\\' : '/'
        end

      end
    end
  end
end
