#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'keylime'
require 'parallel'

ENDPOINT = ENV['CIRCLECI_ENDPOINT'] || 'https://circleci.com'

def token
  return @token if @token
  credential = Keylime.new(server: ENDPOINT)
  @token = credential.get!("CircleCI Token (#{ENDPOINT}/account/api)").password
end

def api_url(path)
  "#{ENDPOINT}/api/v1.1/#{path}?circle-token=#{token}"
end

def api_req(path)
  JSON.parse(open(api_url(path)).read)
end

def all_projects
  api_req('projects').map do |project|
    "#{project['username']}/#{project['reponame']}"
  end
end

def status(project)
  build = api_req("project/github/#{project}").first
  build ? build['status'] : 'new'
end

def all_statuses
  Parallel.map(all_projects) { |x| [x, status(x)] }.to_h
end

def failing_projects
  all_statuses.reject { |_, v| %w(success fixed running).include? v }
end

def print_report!
  list = failing_projects.to_a.sort_by(&:first)
  list.map! { |project, state| ['https://circleci.com/gh/' + project, state] }
  url_width = list.map(&:first).map(&:size).max
  list.each { |url, state| puts "#{url.ljust(url_width)} #{state}" }
end

print_report!
