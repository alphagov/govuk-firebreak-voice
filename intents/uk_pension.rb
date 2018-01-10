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
  respond("What can Gov.uk tell you")
end

intent "SessionEndedRequest" do
  respond
end


intent "getDate" do
  session = load_session(request)
  if session.can?(:get_date)
    session.perform(:add_date, field: :date)
    if session.valid?
      confirm_action(session)
    else
      build_reask_action(session)
    end
  else
    build_action_not_alllowed(session)
  end
end

intent "getNumber" do
  session = load_session(request)
  if session.can?(:get_number)
    session.perform(:add_number, field: :number)
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
  session = load_session(request)
  session.perform(:add_date, field: :birthday)
  build_ask_action(session)
end

def load_session(request)
  Session.new(
    last_request: request.session_attributes('last_request'),
    allowed_actions: request.session_attributes('allowed_actions'),
  )
end

def build_ask_action(session)
  if session.complete?
    ask(*session.ask_details)
  else
    build_answer(session)
  end
end

class Session
  def initialize(last_request:, allowed_actions:)
    @last_request = last_request
    @allowed_actions = allowed_actions
  end

  def complete?
    false # TODO: add this
  end

  def next_action
    :birthday # TODO: calc this
  end

  def ask_details
    case next_action
    when :birthday
      question = "Ok, what’s your date of birth?"
      allowed_actions = %(getDate getNumber)
    end

    [question, session_attributes: { last_request: question, allowed_actions: allowed_actions }]
  end

  def attributes
    {
      last_request: @last_request,
      allowed_actions: @allowed_actions
    }
  end
end
