#encoding: utf-8
require 'rest-client'
require 'nokogiri'
require 'uri'

module Hodor
  class Hodor
    def initialize(url)
      parts = URI.split(url)
      @base = parts[0] + '://' + parts[2]
      @doc = Nokogiri::HTML(RestClient.get(url))
      @source_charset = (@doc.xpath('//meta/@charset').first || 'UTF-8').to_s
    end

    def hodor
      @doc.xpath('//div|//span|//img/@alt|//a').each { |node| node_hodor node }
      @doc.xpath('//script/@src|//img/@src|//link/@href').each { |node| src_hodor node }
      @doc.to_xml(:indent => 2)
    end

    def node_hodor(node)
      node.content = make_hodor(node.content) if node.text?
      node.children.each { |child| node_hodor child }
    end

    def src_hodor(attr)
      attr.content = 'http:' + attr.content if attr.content.start_with?('//')
      attr.content = @base + '/' + attr unless attr.content =~ /^http/
    end

    def make_hodor(not_hodor)
      not_hodor.encode('UTF-8', @source_charset, {:invalid => :replace}).
        gsub(/\p{Ll}\p{Alpha}*/, 'hodor').
        gsub(/\p{Lu}\p{Alpha}*/, 'Hodor')
    end
  end
end
