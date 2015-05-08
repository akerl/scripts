#!/usr/bin/env ruby

require 'keychain'
require 'mercenary'
require 'linodeapi'
require 'securerandom'

keychain = Keychain.default.generic_passwords.where(service: 'vagrant-linode')
fail('Failed to load keychain') unless keychain.first
key = keychain.first.password

API = LinodeAPI::Raw.new(apikey: key)

linodes = API.linode.list

Mercenary.program(:spawn_linode) do |p|
  p.version '0.0.1'
  p.description 'Management script for short-lived VMs'
  p.syntax 'spawn_linode <subcommand> [args]'

  p.command(:list) do |c|
    c.syntax 'list'
    c.description 'List existing VMs'

    c.action do |args, _|
      ips = API.linode.ip.list.select { |x| x.ispublic == 1 }
      linode_ips = ips.map { |x| [x.linodeid, x.ipaddress] }.to_h
      linodes.each do |linode|
        puts "#{linode.label}: #{linode_ips[linode.linodeid]}"
      end
    end
  end

  p.action do
    puts p
    exit 1
  end
end
