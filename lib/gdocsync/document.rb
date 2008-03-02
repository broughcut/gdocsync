require 'gdocsync/session'
require 'gdocsync/call'

require 'rubygems'
require 'mechanize'
require 'hpricot'
require 'digest/sha2'

module Gdocsync

  class Document

    attr_reader :id, :title, :updated_at, :uri

    def initialize(title=nil,id=nil,uri=nil,updated_at=nil)
      @title = title
      @id = id
      @uri = uri
      @updated_at = updated_at
    end
    
    
    def self.find(param)
      case param
      when :all
        items = []
        doc = Call.new(:get).response
        (doc/:entry).each do |entry|
          item = {}
          item[:title] = entry.at(:title).inner_text
          item[:updated_at] = entry.at(:updated).inner_text
          item[:id] = entry.at(:id).inner_text.gsub(/^.*\/|\?.*$/){}
          item[:uri] = (doc/"link[@type='text/html']")[0].attributes['href']
          items << item
        end
      end
      found = []
      items.each do |entry|
        found << Document.new(entry[:title],entry[:id],entry[:uri],entry[:updated_at])
      end
      found
    end
   
    def create!
    end


    def delete!
    end


  end

end
