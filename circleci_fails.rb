#!/usr/bin/env ruby

require 'open-uri'
require 'json'

def request_token
  `stty -echo`
  print 'Please enter CircleCI token: '
  gets
ensure
  `stty echo`
end

token = ENV['CIRCLECI_TOKEN'] || request_token
raw = open("https://circleci.com/api/v1/projects?circle-token=#{token}")
json = JSON.load(raw)

repos = json.map do |x|
  name = x['vcs_url'][19..-1]
  status = x['branches']['master']['recent_builds'].first['status']
  [name, status]
end
repos.sort! { |a, b| a.first <=> b.first }
repos.reject! { |name, state| ['success', 'fixed'].include? state }

repos.each { |name, state| puts "#{name}: #{state}" }
