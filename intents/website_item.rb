intent 'website_item' do
  item = request.slot_value('websiteItem')
  msg = <<~MSG
    You can find out about #{item} on the GOV.UK website. 
    I’ve added the link to a card in your Alexa app. You can also 
    the website and search for #{item}.
  MSG

  card = card(item, "Find out more details at https://www.gov.uk/#{item.downcase.tr(' ', '-')}", "https://assets.publishing.service.gov.uk/static/images/gov.uk_logotype_crown-ea874a79e09423d63420aff44f016fd0b92dc6dec0cc2668d63b150c8669875e.png")

  tell(msg, card: card)
end
