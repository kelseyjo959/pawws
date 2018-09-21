#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'


doc = Nokogiri::HTML(open('https://www.strayrescue.org/sgt-devoy'), 
                           nil,
                           'UTF-8')
info = {}

devoy =  doc.xpath("//div[@class='itemHeader']/h2").first.content
devoy = devoy.delete!("\t")
devoy = devoy.delete!("\n")
info[:name] = devoy

doc.xpath("//div[@class='itemExtraFields']/ul/li").each do |li|
  
  spans =  li.xpath("span")
  spans.first.content.inspect
  spans[1].content.inspect
  case spans.first.content 
  when /^Age:$/
    info[:age] = spans[1].content
  when /^Breed:$/
    info[:breed] = spans[1].content
  when /^Type:$/
    info[:species] = spans[1].content
  when /^Gender:$/
    info[:gender] = spans[1].content
  end 
end

img_src = doc.xpath("//div[@class='itemImageBlock']/span[@class='itemImage']/a/@href")
info[:img_src]  = "https://www.strayrescue.org#{img_src}"  

puts info



