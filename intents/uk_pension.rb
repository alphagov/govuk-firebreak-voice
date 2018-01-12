require 'date'

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
  session = Session.load_session(request)

  question, args = session.dup_previous_details
  respond("I need this information in order to correctly determine when you can get your pension. #{question}", args)
end

intent "SessionEndedRequest" do
  respond
end

intent "AMAZON.YesIntent" do
  session = Session.load_session(request)
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
