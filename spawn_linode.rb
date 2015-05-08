#!/usr/bin/env ruby

require 'keychain'
require 'mercenary'
require 'linodeapi'
require 'securerandom'

keychain = Keychain.default.generic_passwords.where(service: 'vagrant-linode')
fail('Failed to load keychain') unless keychain.first
key = keychain.first.password

API = LinodeAPI::Raw.new(apikey: key)

p API.linode.list

