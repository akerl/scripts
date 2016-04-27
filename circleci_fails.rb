#!/usr/bin/env ruby

require 'open-uri'
require 'json'
require 'keylime'

ENDPOINT = ENV['CIRCLECI_ENDPOINT'] || 'https://circleci.com'

credential = Keylime.new(server: ENDPOINT)
token = credential.get!("CircleCI Token (#{ENDPOINT}/account/api)").password

raw = open("#{ENDPOINT}/api/v1/projects?circle-token=#{token}")
json = JSON.load(raw)

repos = json.map do |x|
  url = x['vcs_url'].sub('github.com', 'circleci.com/gh')
  status = x['branches']['master']['recent_builds'].first['status']
  [url, status]
end
repos.reject! { |_, state| ['success', 'fixed'].include? state }
repos.sort_by!(&:first)

url_width = repos.map(&:first).map(&:size).max

repos.each { |url, state| puts "#{url.ljust(url_width)} #{state}" }