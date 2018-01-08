intent "state_pension_available" do
  birthday = slot_value('birthday')
  r = `curl https://www.gov.uk/state-pension-age/y/age/#{birthday.strftime('yyyy-mm-dd')}/male.json`
  ask(JSON.parse(r)['title'])
end

intent "SessionEndedRequest" do
  respond
end
