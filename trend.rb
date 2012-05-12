#!/usr/bin/ruby
require 'nokogiri'
require 'open-uri'
require './tradeking.rb'

stocks = {}
tickers = []

`rm data.txt`

@tk = TK.new

loop do
	if (Time.now.hour >= 6 && Time.now.min >= 30) && Time.now.hour <= 13

		#only track trending stocks within the first 30 minutes because they
		#might have some momentum
		if (Time.now.hour == 6 && Time.now.min >= 30) && Time.now.hour < 7
			begin
				doc = Nokogiri::HTML(open("http://stocktwits.com"))

				doc.xpath("//div[@id='trending-container']//a").each do |a|
					ticker = a.content.gsub("$", "")

					if !stocks[ticker]
						time = Time.now
						quote = @tk.quote(ticker)
						price = quote['last']
						open = quote['opn']

						#BUY BUY BUY
						if(((price.to_f-open.to_f)/price.to_f)*100 > 1.5)
							tickers << ticker
							stocks[ticker] = price.to_f
						else
							stocks[ticker] = "nope"
						end

						puts "#{ticker},#{time},#{price},#{open}"

						File.open("data.csv", "a+") do |f|
							f.write "#{ticker},#{time},#{price},#{open}"
						end
					end
				end
			rescue
				puts "Oops"
			end
		#try to figure out when to sell
		else
			quotes = @tk.quotes(tickers)

			quotes.each do |q|
				price = q['last'].to_f
				bought = stocks[q['symbol']]

				#SELL SELL SELL
				if q['hi'].to_f - q['last'].to_f <= 0.5 && bought < price
					profit = (price * 100) - (bought * 100)

					File.open("sales.log", "a+") do |f|
						f.write "#{q['symbol']} :: $#{profit}"
					end

					#stop trading this stock
					stocks.delete(q['symbol'])
				end
			end
		end
	else 
		stocks = {}
		puts "Market not open"
	end

	sleep(30)

end