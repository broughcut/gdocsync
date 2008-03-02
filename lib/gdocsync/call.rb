require 'gdocsync/session'

require 'rubygems'
require 'net/http'
require 'mechanize'
require'eventmachine'
require 'hpricot'


module Gdocsync

  class Call

    attr_reader :response, :request, :user,:status,:retries,:method
    attr_writer :response, :status, :retries


    def initialize(method,request=nil,user=GOOGLE_USER)
      @response = nil
      @request = request.to_s
      @user = user
      @status = nil
      @retries = 0
      @method = method
      hit
    end


    def hit
      token = Session.token
      http = Net::HTTP.new("docs.google.com", 80)
      path = "/feeds/documents/private/full"
      headers = {
        "Authorization" => "GoogleLogin auth=\"#{token}\"",
        "Content-Type" => "application/atom+xml"
      }
      case @method
      when :post
      when :get
        response = http.get(path,headers)
      when :delete
      end
      @status = response.code.to_i
      check_response(response)
    end


    def check_response(response)
      case @status
      when 200, 201
        @response = Hpricot.XML(response.body)
      when 404
        @response = 404
      else
        return if @retries > 3
        Session.new
        puts "Setting session"
        @retries += 1
        hit
      end
    end

  end

end

