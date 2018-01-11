require 'open-uri'

class Session
  def self.load_session(request)
    request.session_attribute('last_request')

    Session.new(
      request,
      last_action: request.session_attribute('last_action'),
      last_request: request.session_attribute('last_request'),
      allowed_actions: request.session_attribute('allowed_actions'),
      birthday: request.session_attribute('birthday'),
    )
  rescue NoMethodError
    Session.new(
      request,
      last_action: '',
      last_request: '',
      allowed_actions: %{pension_age},
    )
  end

  def initialize(request, last_action:, last_request:, allowed_actions:, birthday: nil)
    @request = request
    @last_action = last_action
    @last_request = last_request
    @allowed_actions = allowed_actions
    @birthday = birthday

    @next_action = nil
  end

  def can?(action)
    @allowed_actions.include?(action.to_s)
  end

  def perform(action, field:)
    case action
    when :add_date
      @birthday = @request.slot_value(field.to_s)
      if @birthday && Date.parse(@birthday) > Date.today
        @next_action = :birthday_missing_year
      end
    end
  end

  def complete?
    false # TODO: add this
  end

  def next_action
    if !@birthday
      :birthday
    elsif Date.parse(@birthday) < Date.new(1963) && !@gender
      :gender
    else
      if @birthday == 1111
        :complete_birthday
      else
        :confirm_details
      end
    end
  end

  def ask_details
    ssml = false
    case @next_action || next_action
    when :birthday
      question = "Ok what’s your date of birth"
      allowed_actions = %(getDate getNumber)
    when :birthday_missing_year
      question = "Sorry, I need to know the year. What year were you born"
      allowed_actions = %(getDate getNumber)
    when :gender
      question = "I can't process people born before 1963, please use
  <speak><phoneme alphabet=\"ipa\" ph=\"ˈɡʌv\">gov</phoneme> dot uk</speak> to
  get your pension date"
      allowed_actions = %(pension_age)
      ssml = true
    when :confirm_details
      r = open("https://www.gov.uk/state-pension-age/y/age/#{@birthday}/#{@gender || 'male'}.json").read

      question = "Because you were born on #{@birday} #{JSON.parse(r)['title']}"
      allowed_actions = %{pension_age}
        #you can claim your pension on
        #¢DD/MM/YYYY and you will be YY years old."
    else
      raise "Missing action: #{@next_action || next_action}"
    end

    args = {
      session_attributes: {
        last_action: @next_action || next_action,
        last_request: question,
        allowed_actions: allowed_actions,
        birthday: @birthday,
      }
    }

    args[:ssml] = true if ssml
    [
      question,
      args
    ]
  end

  # def change_details
  #   question = "You have said that you were"
  #   question << " born on #{@birthday}" if @changes.include?(:birthday)
  #   question << ". is this correct"
  #   [
  #     question,
  #     session_attributes: {
  #       last_action: 'confirmation',
  #       last_request: question,
  #       allowed_actions: %{getConfirmation},
  #       birthday: @birthday,
  #       full_date: @full_date
  #     }
  #   ]
  # end

  def attributes
    {
      last_request: @last_request,
      allowed_actions: @allowed_actions
    }
  end
end
