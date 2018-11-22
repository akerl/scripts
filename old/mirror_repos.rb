#!/usr/bin/env ruby

require 'keylime'
require 'gitlab'
require 'octoauth'
require 'octokit'

gitlab_endpoint = 'https://gitlab.com'

gitlab_token = Keylime.new(
  server: gitlab_endpoint,
  account: 'prospectus'
).get!("GitLab API token (#{gitlab_endpoint}/profile/account)").password

gitlab_client = Gitlab.client(
  endpoint: gitlab_endpoint + '/api/v4',
  private_token: gitlab_token
)

github_token = Octoauth.new(
  note: 'Prospectus',
  file: :default,
  autosave: true
).token

github_client = Octokit::Client.new(
  access_token: github_token,
  auto_paginate: true
)

all_repos = github_client.repos.reject { |x| x.full_name =~ /^[pt]/ }
priv_repos, pub_repos = all_repos.group_by(&:private).values_at(true, false)

gitlab_repos = gitlab_client.projects(membership: true).auto_paginate
already_migrated = gitlab_repos.map { |x| [x.path_with_namespace, x] }.to_h

namespaces = gitlab_client.namespaces.map { |x| [x.full_path, x.id] }.to_h

pub_repos.each do |repo|
  org = repo.owner.login
  namespace = namespaces[org] || raise("No Gitlab org for #{org}")
  name = repo.name
  name = 'dotdotdot' if name == '...'
  full_name = org + '/' + name
  if already_migrated[full_name.downcase]
    puts "Skipping #{full_name}"
    next
  end
  puts "Importing #{full_name}"
  gitlab_client.create_project(
    name,
    namespace_id: namespace,
    import_url: repo.clone_url,
    visibility: 'public',
    wiki_enabled: false,
    wall_enabled: false,
    issues_enabled: false,
    snippets_enabled: false,
    merge_requests_enabled: false
  )
end

puts "Not migrating private repos: #{priv_repos.map(&:full_name).join(', ')}"
