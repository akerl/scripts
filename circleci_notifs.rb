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
  "#{ENDPOINT}/api/v1/#{path}?circle-token=#{token}"
end

def projects
  raw = Curl::Easy.perform(api_url('projects')).body_str
  json = JSON.parse(raw)
  json.map do |x|
    project = x['username'] + '/' + x['reponame']
    slack_settings = x.select { |k, _| k =~ /^slack_/ }
    [project, slack_settings]
  end.to_h
end

def build_settings(options)
  {
    'slack_webhook_url' => options[:webhook],
    'slack_channel' => nil,
    'slack_notify_prefs' => nil,
    'slack_subdomain' => nil,
    'slack_channel_override' => nil,
    'slack_api_token' => nil
  }
end

def update(project, settings)
  url = api_url("project/#{project}/settings")
  data = JSON.dump(settings)
  req = Curl.put(url, data) do |http|
    http.headers['Content-Type'] = 'application/json'
  end
  return if req.response_code == 200
  raise "#{req.response_code}: #{req.url}"
end

Mercenary.program(:circleci_notifs) do |p|
  p.version '0.0.1'
  p.description 'Update IRC settings for CircleCI builds'
  p.syntax 'circleci_notifs [options]'

  p.option :noop, '-n', '--noop', 'Dry run, print repos that would have changed'
  p.option :webhook, '-w HOOK', '--webhook HOOK', 'Webhook URL'

  p.action do |_, options|
    raise('Please provide webhook') unless options[:webhook]
    new_settings = build_settings(options)
    to_change = projects.select { |_, v| v != new_settings }.keys
    to_change.each do |project|
      puts "Updating settings for #{project}"
      update(project, new_settings) unless options[:noop]
    end
  end
end
