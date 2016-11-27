#!/usr/bin/env ruby

require 'watir'
require 'nokogiri'
require 'mercenary'

class Network
  def initialize(url, file = nil)
    @url = url
    @file = file
  end

  def render
    lines = header
    lines += subnets.map do |subnet|
      section = '## ' + subnet + "\n"
      section += comments[subnet] if comments[subnet]
      section
    end
    lines
  end

  def header
    [
      "# Subnet list\n\n",
      "This list was generated using [subnet_slicer.rb](#{script_url}).\n\n",
      "To update it, [click here](#{@url}) to re-open the existing topology, " \
      "modify it, and then re-run subnet_slicer.rb with the new URL\n\n"
    ]
  end

  def script_url
    'https://github.com/akerl/scripts/blob/master/allprop'
  end

  def browser
    @browser ||= Watir::Browser.new :phantomjs
  end

  def page
    return @page if @page
    browser.goto(@url)
    @page = Nokogiri::HTML(browser.html)
  end

  def table
    @table ||= page.at_css('#calcbody')
  end

  def subnets
    @subnets ||= table.xpath('tr/td[1]').map(&:text)
  end

  def old_file
    @old_file ||= File.readlines(@file)
  end

  def comments
    return @comments if @comments
    chunks = old_file.chunk_while { |_, b| ! b.start_with? '## ' }
    @comments = chunks.map { |x| [x.shift.split[1], x.join] }.to_h
  end
end

Mercenary.program(:subnet_slicer) do |p|
  p.description 'Track subnets using Visual Subnet Calculator'
  p.syntax 'subnet_slicer [options] URL'

  p.option :file, '-f FILE', '--file FILE', 'File for loading existing comments'
  p.option :overwrite, '-o', '--overwrite', 'Write results directly to file'

  p.action do |_, options|
    url = ARGV.shift
    file = options[:file]
    unless url
      puts p
      exit 1
    end
    results = Network.new(url, file).render
    if options[:overwrite]
      raise('No file provided') unless file
      File.open(file, 'w') { |fh| results.each { |x| fh << x } }
    else
      puts results
    end
  end
end
