require 'open-uri'
require 'nokogiri'
intent 'minister_for_cabinet_office' do
  html = open('https://www.gov.uk/government/ministers/minister-for-the-cabinet-office').read
  title = Nokogiri.parse(html).css('.current-role-holder h1').first.value
  title.gsub!(/^Current role holder: /, '')

  tell("#{title} is the minister for Cabinet Office")
end
