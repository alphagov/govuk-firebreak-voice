require 'date'

class PensionAge
  def initialize(request)
    @request = request
  end

  def birthday
    @request['intent']['slots']['birthday']['value'] unless ['intent']['slots']['gender']['confirmationStatus'] == 'DENIED'
  end

  def birthday?
    birthday && birthday =~ /\A\d\d\d\d-\d?\d-\d?\d\Z/ && birthday !~ /\A#{Date.today.year}/
  end

  def gender
    @request['intent']['slots']['gender']['value'] unless ['intent']['slots']['gender']['confirmationStatus'] == 'DENIED'
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
  respond(
    <<~MSG
      Hi this skill allows you to ask, 
      When do I get my pension,
      When is the queens birthday,
      Who is the minister for the cabinet office or
      Can I claim Universal credit.
      Please say list options to here this again.
    MSG
  )
end

intent 'list_commands' do
  respond(
    <<~MSG
      Please try 
      When do I get my pension,
      When is the queens birthday,
      Who is the minister for the cabinet office or
      Can I claim Universal credit.
  MSG
  )
end

intent 'why_dob' do
  session = load_session(request)

  question, args = session.dup_previous_details
  respond("I need this information in order to correctly determine when you can get your pension. #{question}", args)
end

intent "SessionEndedRequest" do
  respond
end

intent "AMAZON.YesIntent" do
  session = load_session(request)
  if session.can?(:YesIntent)
    session.confirm_intent
    question, args = session.ask_details

    ask(question, args)
  else
    question, args = session.dup_previous_details
    respond("I'm sorry that is not a valid response. #{question}", args)
  end
end

intent "getDate" do
  session = Session.load_session(request)
  if session.can?(:getDate)
    session.add_date(field: :date)
    question, args = session.ask_details

    ask(question, args)
  else
    question, args = session.dup_previous_details
    respond("I'm sorry that is not a valid response. #{question}", args)
  end
end

intent "getNumber" do
  session = Session.load_session(request)
  if session.can?(:getNumber)
    session.add_date(field: :number)
    question, args = session.ask_details

    ask(question, args)
  else
    question, args = session.dup_previous_details
    respond("I'm sorry that is not a valid response. #{question}", args)
  end
end

intent "pension_age" do
  session = Session.load_session(request)
  if session.can?(:pension_age)
    session.add_date(field: :birthday)
    question, args = session.ask_details

    ask(question, args)
  else
    # should this reset the session?
    question, args = session.dup_previous_details
    respond("I'm sorry that is not a valid response. #{question}", args)
  end
end
