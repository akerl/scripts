#!/usr/bin/env ruby

require 'yaml'

data = File.open('pokemon.yml') { |fh| YAML.load(fh) }

hashed_list = data.each_with_object(Hash.new { 0 }) do |entry, acc|
  name = entry['of'] || entry['name']
  acc[name] += entry['need']
end

sorted_list = hashed_list.to_a.sort { |a, b| a.last <=> b.last }

sorted_list.each { |name, count| puts "#{count.to_s.rjust(2)}  #{name}" }

puts sorted_list.map(&:first).join(',')

