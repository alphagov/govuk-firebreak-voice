intent 'website_item' do
  item = request.slot_value('websiteItem')
  msg = <<~MSG
    You can find out about #{item} on the GOV.UK website. 
    I’ve added the link to a card in your Alexa app.
  MSG

  card = card(item, "Find out more details at https://www.gov.uk/#{item.downcase.tr(' ', '-')}", "https://assets.publishing.service.gov.uk/static/images/gov.uk_logotype_crown.png")

  ask(msg, card: card)
end
