intent "state_pension_available" do
  birthday = request.slot_value('birthday')
  r = `curl https://www.gov.uk/state-pension-age/y/age/#{birthday}/male.json`
  ask(JSON.parse(r)['title'])
end

intent "LaunchRequest" do
  respond("What can Gov.uk tell you")
end

intent "SessionEndedRequest" do
  respond
end
