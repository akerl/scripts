#!/usr/bin/env ruby

require 'octokit'
require 'octoauth'

Octokit.auto_paginate = true
Token = Octoauth.new note: 'collect', file: :default
Client = Octokit::Client.new(access_token: Token.token)

def parse(array)
  array.map { |x| [x[:full_name], Date.parse(x[:created_at].to_s)] }
end

repos = parse Client.repos
orgs = Client.orgs.map(&:login)
orgs.delete 'linode'
orgs.each do |org|
  repos += parse(Client.organization_repositories(org))
end

repos.sort! { |a, b| a.last <=> b.last }
repos.each { |repo, date| puts "#{date}: created #{repo}" }
