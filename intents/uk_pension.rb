intent "state_pension_available" do
  birthday = request.slot_value('birthday')
  gender = request.slot_value('gender')
  if birthday && birthday != '' && gender && gender != ''
    r = `curl https://www.gov.uk/state-pension-age/y/age/#{birthday}/male.json`
    tell(JSON.parse(r)['title'])
  else
    puts '--------'
    puts "No birthday"
    puts '--------'
    dialog_delegate
  end
end

intent "simple_state_pension" do

  birthday = request.slot_value('birthday')
  gender = request.slot_value('gender')
  url = "https://www.gov.uk/state-pension-age/y/age/#{birthday}/#{gender}.json"
  puts "curling #{url}"
  r = `curl #{url}`
  tell(JSON.parse(r)['title'])
end

intent "LaunchRequest" do
  respond("What can Gov.uk tell you")
end

intent "SessionEndedRequest" do
  respond
end
