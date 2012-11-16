require 'eventmachine'
require 'pry'
require 'em-http-request'
require 'json'
require 'tweetstream'
require 'twitter'
require 'term/ansicolor'
require 'symbolmatrix'
require 'fetcher-microdata-twitter'
require 'em-websocket-client'


CONFIG = SymbolMatrix.new "config/config.yaml" 

TweetStream.configure do |config|
  config.consumer_key       = CONFIG.consumer_key
  config.consumer_secret    = "zhzEDv12a87RimkvaisEi5IZvqISzEVmf2gDIJQCuw"
  config.oauth_token        = "308762265-ahoa4FzpufTaPRghxHsChqwTwMRIRaJfHkmkn5Ip"
  config.oauth_token_secret = "UwAWZJlhSGiBNgbHtDqiS2ILZJuprd091rUNbETE"
  config.auth_method        = :oauth
end

class String; include Term::ANSIColor ; end


EventMachine.run {
  puts "Connecting to ws://bridge.fetcher:8080/".blue
  websocket_client = EventMachine::WebSocketClient.connect("ws://bridge.fetcher:8080/")
  puts "Connected".dark

  TweetStream::Client.new.userstream do |tweet|
    begin
      puts tweet.to_hash.to_json.blue
      in_microdata = Fetcher::Microdata::ArticleSmall.new(
        JSON.parse(tweet.to_hash.to_json), 
        #current_user
      )
      puts "Sending tweet to Bridge:".intense_blue
      puts tweet.to_hash.to_json.blue
      websocket_client.send_msg tweet.to_hash.to_json
      puts "Sent".dark
      puts
    rescue Exception => e
      puts e.message.red
      puts
    end
  end  
}