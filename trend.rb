#!/usr/bin/ruby
require 'nokogiri'
require 'open-uri'
require './tradeking.rb'

trending = {}
bought = {}
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

					if !trending[ticker]
						trending[ticker] = Time.now
						time = Time.now
						quote = @tk.quote(ticker)
						price = quote['last'].to_f
						open = quote['opn'].to_f

						#BUY BUY BUY
						if(((price-open)/price)*100 > 1.5)
							tickers << ticker
							bought[ticker] = price
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
				bought = bought[q['symbol']]

				#SELL SELL SELL
				if q['hi'].to_f - q['last'].to_f <= 0.05 && bought < price
					profit = (price * 100) - (bought * 100)

					File.open("sales.log", "a+") do |f|
						f.write "#{q['symbol']} :: $#{profit}"
					end

					#stop trading this stock
					tickers.delete(q['symbol'])
				end
			end
		end
	else 
		trending = {}
		puts "Market not open"
	end

	sleep(30)

end