require 'gdocsync/session'
require 'gdocsync/call'

require 'rubygems'
require 'mechanize'
require 'hpricot'
require 'digest/sha2'
require 'redcloth'

module Gdocsync

  class Document

    attr_reader :id, :title, :updated_at, :uri, :markdown, :raw
    attr_writer :markdown, :raw

    def initialize(title=nil,id=nil,updated_at=nil,raw=nil,markdown=nil)
      @title = title
      @id = id
      @markdown = markdown
      @raw = raw
      @updated_at = updated_at
    end
    
    
    def self.find(param,param2=nil)
      case param
      when :all
        items = []
        doc = Call.new(:get).response
        (doc/:entry).each do |entry|
          item = {}
          item[:title] = entry.at(:title).inner_text
          item[:updated_at] = entry.at(:updated).inner_text
          item[:id] = entry.at(:id).inner_text.gsub(/^.*%3A/){}
          if param2 == :fetch
            body = Call.new(:get, :body, item[:id]).response
            item[:raw] = body 
          end
          items << item
        end
      end
      found = []
      items.each do |entry|
        found << Document.new(entry[:title],entry[:id],entry[:updated_at],entry[:raw],entry[:markdown])
      end
      found
    end

    def self.find_by_title(title,param=nil)
      result = "Document #{title} not found."
      Document.find(:all).each {|doc|
        result = doc if doc.title == title
      }
      if param == :fetch
        body = Call.new(:get, :body, result.id).response
        result.raw = body
      end
      result
    end

    def markdown
      to_markdown
    end

    def redcloth
      RedCloth.new(to_markdown).to_html(:markdown)
    end

    def create!
    end


    def delete!
    end

    private

    def to_markdown
      tmp = File.new("#{RAILS_ROOT}/tmp/gdocsync_document.tmp","w+")
      tmp.puts raw;tmp.close
      markdown = `python #{Dir.pwd}/lib/html2text.py #{RAILS_ROOT}/tmp/gdocsync_document.tmp`
    end


  end

end
