require 'rubygems'
require 'oauth'
require 'json'
require 'yaml'

class TK
	@config = YAML::load( File.read('tradeking.yml') )

	@consumer = OAuth::Consumer.new @config['consumer_key'], @config['consumer_secret'], { :site => 'https://api.tradeking.com' }
	@@access_token = OAuth::AccessToken.new(@consumer, @config['access_token'], @config['access_token_secret'])

	def quote(ticker)
		resp = @@access_token.get("/v1/market/ext/quotes.json?symbols=#{ticker}", {'Accept' => 'application/json'}).body

		resp = JSON.parse(resp)

		resp['response']['quotes']['quote']
	end
end
