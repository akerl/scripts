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

def update(project, key, value)
  url = api_url("project/github/#{project}/envvar")
  data = JSON.dump('name' => key, 'value' => value)
  req = Curl.post(url, data) do |http|
    http.headers['Content-Type'] = 'application/json'
  end
  return if req.response_code < 202
  raise "#{req.response_code}: #{req.url}"
end

Mercenary.program(:circleci_envvar) do |p|
  p.description 'Update environment settings for CircleCI builds'
  p.syntax 'circleci_envvar [options] PROJECT KEY VALUE'

  p.option :noop, '-n', '--noop', 'Dry run, print change'

  p.action do |_, options|
    project, key, value = ARGV.shift 3
    unless value
      puts p
      exit 1
    end
    puts "Updating #{project} with #{key} = #{value}"
    update(project, key, value) unless options[:noop]
  end
end
