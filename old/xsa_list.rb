#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'

URL = 'http://xenbits.xen.org/xsa/'.freeze
XPATH = '/html/body/table/tr'.freeze

##
# Vuln object
class XSA
  def initialize(raw)
    @data = raw.xpath('td').map { |y| y.children.map(&:text) }
  end

  def id
    @id ||= @data[0].first.split('-').last.to_i
  end

  def release_dt
    @release_dt ||= Date.parse(@data[1].first)
  end

  def update_dt
    return false if @update_dt == false
    @update_dt ||= Date.parse(@data[2].first)
  rescue TypeError
    @update_dt = false
  end

  def version
    @version ||= @data[3].first.to_i
  end

  def cves
    @cves ||= @data[4]
  end

  def title
    @title ||= @data[5].first
  end
end

LIST = Nokogiri::HTML(open(URL)).xpath(XPATH)[1..-1].map { |x| XSA.new(x) }

LIST.reverse.each do |xsa|
  puts [
    xsa.id.to_s.rjust(3),
    xsa.release_dt.to_date,
    xsa.update_dt ? xsa.update_dt.to_date : ' ' * 10,
    xsa.version,
    xsa.title
  ].join(' | ')
end
