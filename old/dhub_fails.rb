#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'parallel'

ORGS = %w[akerl dock0 amylum halyard].freeze
GOOD_STATUSES = %i[success].freeze

BASE_URL = 'https://hub.docker.com/r'.freeze
REPO_XPATH = '//div[contains(@class, "RepositoryListItem__repoName___")]'.freeze
STATUS_XPATH = '//span[contains(@class, "BuildStatus__statusWrapper__")]'.freeze

def get_xpath(url, xpath)
  Nokogiri::HTML(open(url)).xpath(xpath).map(&:text)
end

def fetch_repos(org, stack = [], index = 1)
  results = get_xpath("#{BASE_URL}/#{org}?page=#{index}", REPO_XPATH)
  results.empty? ? stack : fetch_repos(org, stack + results, index + 1)
end

def fetch_status(repo)
  url = "#{BASE_URL}/#{repo}/builds"
  get_xpath(url, STATUS_XPATH).map { |x| x.strip.downcase.to_sym }
end

repos = ORGS.flat_map { |org| fetch_repos(org) }
statuses = Parallel.map(repos) { |repo| [repo, fetch_status(repo).first] }
fails = statuses.reject { |_, status| GOOD_STATUSES.include? status }
fails.each { |repo, status| puts "#{BASE_URL}/#{repo} #{status}" }
