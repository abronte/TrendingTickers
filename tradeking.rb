require 'rubygems'
require 'oauth'
require 'json'
require 'yaml'

class TK
	@config = YAML::load( File.read('tradeking.yml') )

	@consumer = OAuth::Consumer.new @config['consumer_key'], @config['consumer_secret'], { :site => 'https://api.tradeking.com' }
	@@access_token = OAuth::AccessToken.new(@consumer, @config['access_token'], @config['access_token_secret'])

	def quote(ticker)
		ext_quotes(ticker)
	end

	def quotes(tickers)
		ext_quotes(tickers.join(','))
	end

	private

	def ext_quotes(str)
		resp = @@access_token.get("/v1/market/ext/quotes.json?symbols=#{str}", {'Accept' => 'application/json'}).body
		resp = JSON.parse(resp)

		resp['response']['quotes']['quote']
	end
end
