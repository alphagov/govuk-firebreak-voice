require 'date'

class PensionAge
  def initialize(request)
    @request = request
  end

  def birthday
    @request['intent']['slots']['birthday']['value']
  end

  def birthday?
    birthday && birthday =~ /\A\d\d\d\d-\d?\d-\d?\d\Z/ && birthday !~ /\A#{Date.today.year}/
  end

  def gender
    @request['intent']['slots']['gender']['value']
  end

  def valid?
    has_all_fields? && !pending_dialog?
  end

  def has_all_fields?
    gender && birthday && birthday?
  end

  def pending_dialog?
    @request['dialogState'] && @request['dialogState'] != 'COMPLETED'
  end
end

intent "simple_state_pension" do
  pension_age = PensionAge.new(request.instance_variable_get(:@request)['request'])

  if pension_age.valid?
    r = `curl https://www.gov.uk/state-pension-age/y/age/#{pension_age.birthday}/#{pension_age.gender}.json`
    tell(JSON.parse(r)['title'])
  elsif pension_age.birthday && !pension_age.birthday?
    puts "invalid birthday"
    dialog_elicit("Please enter your full birthday including month and year", 'birthday')
  else
    puts "delegate"
    dialog_delegate
  end
end

intent "LaunchRequest" do
  respond("What can Gov.uk tell you")
end

intent "SessionEndedRequest" do
  respond
end
