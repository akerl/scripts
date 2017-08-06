#!/usr/bin/env ruby

require 'octoauth'

token = Octoauth.new(note: 'issues', files: [:default]).token
CLIENT = Octokit::Client.new(access_token: token, auto_paginate: true)

def check_second(name, first, method)
  puts 'Checking ' + name
  first_ids = first.map(&:id)
  results = first.flat_map do |human|
    CLIENT.send(method, human.login).reject { |x| first_ids.include? x.id }
    print '.'
    sleep 1
  end
  puts
  results
end

first_humans = (CLIENT.following + CLIENT.followers).uniq(&:id)
first_stars = CLIENT.starred

second_humans = check_second('humans', first_humans, :following)
second_stars = check_second('stars', first_stars, :starred)

puts 'Second degree humans:'
second_humans.each { |x| puts "#{x.login} #{x.html_url}" }
puts
puts 'Second degree stars:'
second_stars.each { |x| puts "#{x.full_name} #{x.html_url} #{x.description}" }
