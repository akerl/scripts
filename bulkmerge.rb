#!/usr/bin/env ruby

require 'octoauth'

auth = Octoauth.new(
  note: 'spaarti',
  file: '~/.octoauth.d/spaarti.yml',
  autosave: true,
)

client = Octokit::Client.new(
    access_token: auth.token,
    auto_paginate: true
)

orgs = client.org_memberships.group_by(&:role)['admin'].map { |x| x.organization.login }
query = "is:open is:pr archived:false user:#{client.login}" + orgs.map { |x| " user:#{x}" }.join('')
prs = client.search_issues(query).items

prs.each do |pr|
  repo = Octokit::Repository.from_url pr.repository_url
  print "#{pr.html_url} #{repo} #{pr.title} (#{pr.user.login})?"
  gets
  client.merge_pull_request(repo, pr.number, '', merge_method: 'squash')
end
