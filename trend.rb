#!/usr/bin/ruby
require 'nokogiri'
require 'open-uri'
require './tradeking.rb'

stocks = {}

`rm data.txt`

@tk = TK.new

loop do
	if Time.now.hour >= 5 && Time.now.hour < 15
		begin
			doc = Nokogiri::HTML(open("http://stocktwits.com"))

			doc.xpath("//div[@id='trending-container']//a").each do |a|
				ticker = a.content.gsub("$", "")

				if !stocks[ticker]
					time = Time.now
					stocks[ticker] = time
					quote = @tk.quote(ticker)
					price = quote['last']
					trend = quote['trend']

					puts "#{ticker} :: #{price} :: #{trend} @ #{time}"

					File.open("data.txt", "a+") do |f|
						f.write "#{ticker} :: #{price} :: #{trend} :: #{time}\n"
					end
				end
			end
		rescue
			puts "Oops"
		end
	else 
		puts "Market not open"
	end

	sleep(60)

end