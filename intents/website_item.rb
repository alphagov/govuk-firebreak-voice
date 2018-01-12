intent 'website_item' do
  item = request.slot_value('websiteItem')
  msg = <<~MSG
    Sorry I don’t know the answer to that. You can find out about #{item} 
    on the <phoneme alphabet=\"ipa\" ph=\"ˈɡʌv\">gov</phoneme> dot UK website. I’ve added the link to a card in your Alexa app
    Would you like to know anything else
  MSG

  card = card(item, "Find out more details at https://www.gov.uk/#{item.downcase.tr(' ', '-')}", "https://assets.publishing.service.gov.uk/static/images/gov.uk_logotype_crown.png")

  ask(msg, card: card)
end
