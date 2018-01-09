require 'date'

class PensionAge
  def initialize(request)
    @request = request
  end

  def birthday
    b = @request['slots']['birthday']['value']
    puts "birthday is: `#{b}` of type #{b.class}"
    b
  end

  def birthday?
    birthday && birthday =~ /\A\d\d\d\d-\d?\d-\d?\d\Z/ && birthday !~ /\A#{Date.today.year}/
  end

  def gender
    @request['slots']['gender']['value']
  end

  def valid?
    has_all_fields? && !pending_dialog?
  end

  def has_all_fields?
    gender && birthday && birthday?
  end

  def pending_dialog?
    @request['request']['dialogState'] && @request['request']['dialogState'] != 'COMPLETED'
  end
end



intent "state_pension_available" do
  pension_age = PensionAge.new(request.instance_variable_get(:@request)['request'])

  if pension_age.valid?
    r = `curl https://www.gov.uk/state-pension-age/y/age/#{pension_age.birthday}/#{pension_age.gender}.json`
    tell(JSON.parse(r)['title'])
  elsif pension_age.birthday && !pension_age.birthday?
    dialog_elicit("Please enter your full birthday including month and year", 'birthday')
  else
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
