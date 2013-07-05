require 'rest-client'
require 'nokogiri'
require 'uri'

module Hodor
  class Hodor
    def hodor(url)
      parts = URI.split(url)
      base = parts[0] + '://' + parts[2]

      doc = Nokogiri::HTML(RestClient.get(url))
      doc.xpath('//div').each { |node| node_hodor node }
      doc.xpath('//span').each { |node| node_hodor node }
      doc.xpath('//img/@alt').each { |node| node_hodor node }
      doc.xpath('//script/@src').each { |node| src_hodor(node, base) }
      doc.xpath('//link/@href').each { |node| src_hodor(node, base) }
      doc.to_xml(:indent => 2)
    end

    def node_hodor(node)
      node.content = hodor!(node.content) if node.text?
      node.children.each { |child| node_hodor child }
    end

    def src_hodor(attr, base)
      attr.content = base + '/' + attr unless attr.content =~ /^http/
    end

    def hodor!(not_hodor)
      not_hodor.
        gsub(/\p{Ll}\p{Alpha}*/, 'hodor').
        gsub(/\p{Lu}\p{Alpha}*/, 'Hodor')
    end
  end
end

puts Hodor::Hodor.new.hodor ARGV.first
