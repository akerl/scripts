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
    irc_settings = x.select { |k, _| k =~ /^irc_/ }
    [project, irc_settings]
  end.to_h
end

def build_settings(options)
  {
    'irc_server' => options[:server],
    'irc_channel' => options[:channel],
    'irc_username' => options[:username],
    'irc_keyword' => nil,
    'irc_password' => nil,
    'irc_notify_prefs' => nil
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

  p.option :server, '-s SERVER', '--server SERVER', 'IRC server (host:port)'
  p.option :channel, '-c CHANNEL', '--channel CHANNEL', 'Channel'
  p.option :username, '-u USER', '--username USER', 'User (not nick) for bot'

  p.action do |_, options|
    unless options[:server] && options[:channel] && options[:username]
      raise('Please provide server/channel/username')
    end
    new_settings = build_settings(options)
    to_change = projects.select { |_, v| v != new_settings }.keys
    to_change.each do |project|
      puts "Updating settings for #{project}"
      update(project, new_settings) unless options[:noop]
    end
  end
end
