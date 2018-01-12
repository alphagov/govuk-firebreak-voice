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
      Who is the minister for the cabinet office and
      Can I claim Universal credit.
      Please say list commands to here these options again.
    MSG
  )
end

intent 'list_commands' do
  respond(
    <<~MSG
      Hi this skill allows you to ask, 
      When do I get my pension,
      When is the queens birthday,
      Who is the minister for the cabinet office and
      Can I claim Universal credit.
  MSG
  )

end

intent "SessionEndedRequest" do
  respond
end


intent "getDate" do
  session = Session.load_session(request)
  if session.can?(:getDate)
    session.add_date(field: :date)
    question, args = session.ask_details

    ask(question, args)
  else
    Responder.new(self).build_action_not_alllowed(session)
  end
end

intent "getNumber" do
  session = Session.load_session(request)
  if session.can?(:get_number)
    session.add_number(field: :number)
    if session.ready_for_confirmation?
      build_confirm_action(session)
    else
      build_ask_action(session)
    end
  else
    build_action_not_alllowed(session)
  end
end

intent "getConfirmation" do
  session = load_session(request)
  if session.can?(:get_confirmation)
    session.perform(:get_confirmation, field: :confirmation)

    build_ask_action(session)
  else
    build_action_not_alllowed(session)
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
    Responder.new(self).build_action_not_alllowed(session)
  end
end
