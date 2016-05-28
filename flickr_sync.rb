#!/usr/bin/env ruby

require 'flickr_fu'
require 'yaml'
require 'fileutils'

class FlickrClient
  def initialize(params = {})
    @config_file = File.expand_path(params[:config_file] || '~/.flickr.yml')
  end

  def sync!
    photosets.each do |set, photos|
      photos.each do |photo|
        puts "#{set} #{photo.title} #{photo.original_format}"
      end
    end
  end

  def config
    @config ||= YAML.load(File.read(@config_file))
  end

  def api
    @api ||= Flickr.new(key: config['key'], secret: config['secret'])
  end

  def photosets
    return @photosets if @photosets
    sets = api.photosets.get_list(user_id: config['user_id'])
    @photosets = sets.map { |set| [set.title, set.get_photos] }.to_h
  end
end

client = FlickrClient.new
require 'pry'
binding.pry

