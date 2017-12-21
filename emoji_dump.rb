#!/usr/bin/env ruby

require 'limp'
require 'slack-ruby-client'
require 'pry'
require 'json'
require 'open-uri'
require 'mercenary'

def load_from_slack(token)
  client = Slack::Web::Client.new(token: token)
  [client.team_info.team.name, client.emoji_list.emoji]
end

def emojis
  @emojis ||= Limp.tokens.map { |x| load_from_slack(x) }.to_h
end

def count
  puts "Found #{emojis.size} teams"
  puts "Found #{emojis.values.map(&:size).reduce(:+)} emoji"
end

# rubocop:disable Metrics/BlockLength
Mercenary.program(:emoji_export) do |p|
  p.description 'Export emoji info from Slack'
  p.syntax 'emoji_export <subcommand> [options]'

  p.command(:json) do |c|
    c.syntax 'json [options]'
    c.description 'Export as JSON'

    c.action do |_, _|
      puts JSON.pretty_generate(emojis)
    end
  end

  p.command(:repl) do |c|
    c.syntax 'repl [options]'
    c.description 'Launch REPL with emoji info'

    c.action do |_, _|
      count
      binding.pry # rubocop:disable Lint/Debugger
    end
  end

  p.command(:download) do |c|
    c.syntax 'download [options]'
    c.description 'Download emojis'

    c.action do |_, _|
      count
      emojis.each do |team, list|
        total = list.size
        puts "Downloading from #{team}, total #{total}"
        FileUtils.mkdir_p team
        list.each_with_index do |(e_name, e_url), index|
          next if e_url =~ /^alias:/ || e_url =~ /\.gif$/
          puts "  Downloading #{e_name} (#{index}/#{total})"
          file = File.join(team, e_name + '.png')
          File.open(file, 'w') { |fh| fh << open(e_url).read }
        end
      end
    end
  end

  p.action do
    puts p
    exit 1
  end
end
# rubocop:enable Metrics/BlockLength
