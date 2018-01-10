class Session
  def self.load_session(request)
    request.session_attribute('last_request')

    Session.new(
      request,
      last_action: request.session_attribute('last_action'),
      last_request: request.session_attribute('last_request'),
      allowed_actions: request.session_attribute('allowed_actions'),
      birthday: request.session_attribute('birthday'),
      full_date: request.session_attribute('full_date'),
    )
  rescue NoMethodError
    Session.new(
      request,
      last_action: '',
      last_request: '',
      allowed_actions: %{pension_age},
    )
  end

  attr_reader :changes

  def initialize(request, last_action:, last_request:, allowed_actions:, birthday: nil, full_date: false)
    @request = request
    @last_action = last_action
    @last_request = last_request
    @allowed_actions = allowed_actions
    @birthday = birthday
    @full_date = full_date

    @changes = []
  end

  def can?(action)
    @allowed_actions.include?(action.to_s)
  end

  def perform(action, field:)
    case action
    when :add_date
      @changes << 'birthday'
      @birthday = @request.slot_value(field.to_s)
      if @birthday =~ /\A\d\d\d\d-\d\d-\d\d\Z/
        @full_date = true
      end
    end
  end

  def complete?
    false # TODO: add this
  end

  def next_action
    if !@birthday
      :birthday
    elsif !@full_date
      :complete_birthday
    else
      :gender
    end
  end

  def ask_details
    case next_action
    when :birthday
      question = "Ok, what’s your date of birth?"
      allowed_actions = %(getDate getNumber)
    when :gender
      question = "Are you male or female?"
      allowed_actions = %(getGender)
    end

    [
      question,
      session_attributes: {
        last_action: next_action,
        last_request: question,
        allowed_actions: allowed_actions,
        birthday: @birthday,
        full_date: @full_date
      }
    ]
  end

  def change_details
    question = "Ok, what’s your date of birth?"
    allowed_actions = %(getDate getNumber)

  end

  def attributes
    {
      last_request: @last_request,
      allowed_actions: @allowed_actions
    }
  end
end
