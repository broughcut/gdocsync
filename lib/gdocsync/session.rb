require 'rubygems'
require 'mechanize'


require 'mechanize'

module Gdocsync

  class Session

    attr_reader :token


    def initialize(email=GOOGLE_EMAIL,password=GOOGLE_PASS)
      @email = GOOGLE_EMAIL
      @password = GOOGLE_PASS
      @client=WWW::Mechanize.new.post("https://www.google.com/accounts/ClientLogin", {"accountType"=>"GOOGLE","Email"=>email,"Passwd"=>password,"service"=>"writely","source"=>"Gdocsync-App-1"})
      @token=@client.body.split(' ')[2].gsub(/Auth=/){}
      cookie = File.new("#{RAILS_ROOT}/lib/gdocsync/files/session.token","w+")
      cookie.puts @token
      cookie.close
    end


    def self.token
      token = File.readlines("#{RAILS_ROOT}/lib/gdocsync/files/session.token")[0].gsub(/\n/){}
    end
  
  end

end
