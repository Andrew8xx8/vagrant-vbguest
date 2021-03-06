begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant VBGuest plugin must be run within Vagrant."
end

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)

require "vagrant-vbguest/errors"
require 'vagrant-vbguest/helpers'

require 'vagrant-vbguest/machine'

require 'vagrant-vbguest/hosts/base'
require 'vagrant-vbguest/hosts/virtualbox'

require 'vagrant-vbguest/installer'
require 'vagrant-vbguest/installers/base'
require 'vagrant-vbguest/installers/linux'
require 'vagrant-vbguest/installers/debian'
require 'vagrant-vbguest/installers/ubuntu'
require 'vagrant-vbguest/installers/redhat'

require 'vagrant-vbguest/middleware'

require 'vagrant-vbguest/download'

module VagrantVbguest

  class Plugin < Vagrant.plugin("2")

    name "vbguest management"
    description <<-DESC
    Provides automatic and/or manual management of the
    VirtualBox Guest Additions inside the Vagrant environment.
    DESC

    config('vbguest') do
      require File.expand_path("../vagrant-vbguest/config", __FILE__)
      Config
    end

    command('vbguest') do
      require File.expand_path("../vagrant-vbguest/command", __FILE__)
      Command
    end

    # hook after anything that boots:
    # that's all middlewares which will run the buildin "VM::Boot" action
    action_hook(self::ALL_ACTIONS) do |hook|
      hook.after(VagrantPlugins::ProviderVirtualBox::Action::Boot, VagrantVbguest::Middleware)
    end
  end
end
