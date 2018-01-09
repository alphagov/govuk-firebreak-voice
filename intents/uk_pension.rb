intent "state_pension_available" do
  birthday = request.slot_value('birthday')
  if birthday && birthday != ''
    r = `curl https://www.gov.uk/state-pension-age/y/age/#{birthday}/male.json`
    dialog_delegate(JSON.parse(r)['title'])
  else
    puts '--------'
    puts "No birthday"
    puts '--------'
    dialog_delegate
  end
end

intent "LaunchRequest" do
  respond("What can Gov.uk tell you")
end

intent "SessionEndedRequest" do
  respond
end
