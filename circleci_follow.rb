#!/usr/bin/env ruby

require 'curb'
require 'json'
require 'keylime'
require 'mercenary'

ENDPOINT = ENV['CIRCLECI_ENDPOINT'] || 'https://circleci.com'

def token
  return @token if @token
  credential = Keylime.new(server: ENDPOINT)
  @token = credential.get!("CircleCI Token (#{ENDPOINT}/account/api)").password
end

def api_url(path)
  "#{ENDPOINT}/api/v1.1/#{path}?circle-token=#{token}"
end

def follow(project)
  url = api_url("project/github/#{project}/follow")
  req = Curl.post(url)
  return if req.response_code < 202
  raise "#{req.response_code}: #{req.url}"
end

Mercenary.program(:circleci_follow) do |p|
  p.description 'Follow new circle project'
  p.syntax 'circleci_follow [options] PROJECT'

  p.option :noop, '-n', '--noop', 'Dry run, print change'

  p.action do |_, options|
    project = ARGV.shift
    unless project
      puts p
      exit 1
    end
    puts "Following #{project}"
    follow(project) unless options[:noop]
  end
end
