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

  def add_date(field:)
    date = @request.slot_value(field.to_s)
    if date
      if date =~ /\A\d\d\d\d-\d\d-\d\d\Z/
        if Date.parse(date) > Date.today
          if @birthday =~ /\A\d\d\d\d\Z/
            @birthday = date.gsub(/\A\d\d\d\d/, @birthday)
          else
            @birthday = date
            @next_action = :birthday_missing_year
          end
        else
          @birthday = date
        end
      elsif date =~ /\A(19|20)\d\d\Z/
        if @birthday
          @birthday.gsub!(/\A\d\d\d\d/, date)
        else
          @birthday = date
        end
      else
        raise "Unknown date format `#{date}`"
      end
    end
  end

  def complete?
    false # TODO: add this
  end

  def next_action
    if !@birthday
      :birthday
    elsif @birthday =~ /\A\d\d\d\d\Z/ && @birthday.to_i <= 1953
      :gender
    elsif @birthday !~ /\A\d\d\d\d\Z/ && Date.parse(@birthday) < Date.new(1953, 12, 6)
      :gender
    else
      if @birthday =~ /\A\d\d\d\d\Z/
        :want_exact_date
      else
        :confirm_details
      end
    end
  end

  def ask_details
    ssml = false
    reset = false

    case @next_action || next_action
    when :birthday
      question = "Ok what’s your date of birth"
      allowed_actions = %(getDate getNumber)
    when :birthday_missing_year
      question = "Sorry, I need to know the year. What year were you born"
      allowed_actions = %(getDate getNumber)
    when :birthday_missing_day
      question = "What day were you born?"
      allowed_actions = %(getDate)
    when :gender
      question = <<~MSG
        <speak>I can't process people born before 6th December 1953, please use
        <phoneme alphabet=\"ipa\" ph=\"ˈɡʌv\">gov</phoneme> dot uk to
        get your pension date</speak>
      MSG

      reset = true
    when :confirm_details
      r = open("https://www.gov.uk/state-pension-age/y/age/#{@birthday}/#{@gender || 'male'}.json").read
      year = JSON.parse(r)['title'].match(/\d\d\d\d/)[0]
      age = year.to_i - @birthday.to_i

      question = "Because you were born on #{@birthday} #{JSON.parse(r)['title']} and you will be #{age} years old"
      allowed_actions = %{pension_age}
      reset = true

    when :want_exact_date
      r = open("https://www.gov.uk/state-pension-age/y/age/#{@birthday}/#{@gender || 'male'}.json").read
      year = JSON.parse(r)['title'].match(/\d\d\d\d/)[0]
      age = year.to_i - @birthday.to_i
      question =  <<~MSG
        Because you were born on #{@birthday} you can claim your pension on #{year} and you will be #{age} years old. 
        Would you like to know the exact date?
      MSG
      allowed_actions = %{YesIntent pension_age}
    else
      raise "Missing action: #{@next_action || next_action}"
    end

    args = {}

    unless reset
      args[:session_attributes] = {
        last_action: @next_action || next_action,
        last_request: question,
        allowed_actions: allowed_actions,
        birthday: @birthday,
      }
    end

    args[:ssml] = true if ssml
    [question, args]
  end

  def dup_previous_details
    args = {
      session_attributes: {
        last_action: @last_action,
        last_request: @last_request,
        allowed_actions: @allowed_actions,
        birthday: @birthday,
      }
    }
    args[:ssml] = true if @last_request =~ /<speak>/

    [@last_request, args]
  end

  def confirm_intent
    case @last_action
    when 'want_exact_date'
      @next_action = :birthday_missing_day
    else
      raise "Unable to confirm intent for: #{@last_action}"
    end
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
