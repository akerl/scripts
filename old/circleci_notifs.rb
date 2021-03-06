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
    hook = options[:webhook] || raise('Please provide webhook')
    projects.each do |project, settings|
      next if settings['slack_webhook_url'] == hook
      puts "Updating settings for #{project}"
      settings['slack_webhook_url'] = hook
      update(project, settings) unless options[:noop]
    end
  end
end
