#!/usr/bin/env ruby

require 'nokogiri'
require 'date'
require 'curb'

URL = 'https://github.com/%{user}?tab=contributions&from=%{day}'

def parse_score(items)
  commits, issues = items.partition { |x| x =~ /^Pushed / }
  commit_score = commits.reduce(0) { |o, i| o += i.split[1].to_i }
  issue_score = issues.size
  {
    commits: commit_score,
    issues: issue_score
  }
end

def curl
  @curl ||= Curl::Easy.new do |c|
    c.headers['User-Agent'] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
  end
end

def request(url)
  curl.url = url
  curl.perform
  return curl.body_str if curl.response_code == 200
  raise("Got error: #{curl.status}") if curl.response_code != 429
  puts 'Sleeping for rate-limit'
  sleep 20
  request(url)
end

def fetch_day(user, day)
  puts "Fetching #{day.strftime}"
  day_url = URL % { user: user, day: day }
  html = Nokogiri::HTML(request(day_url)).css('.contribution-activity-listing')
  items = html.css('li').map(&:text).map(&:strip)
  parse_score(items)
end

def fetch_history(user, day, results = [])
  day_score = fetch_day(user, day)
  results << day_score
  return results if day_score.values.reduce(:+).zero? && results.size > 365
  sleep 2
  fetch_history(user, day - 1, results)
end

USER = ARGV.first

CURLER = Curl::Easy.new do |curl|
  curl.headers["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
end

require 'pry'
results = fetch_history(USER, Date.today)
binding.pry
