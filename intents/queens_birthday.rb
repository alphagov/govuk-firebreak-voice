require 'date'

intent 'queens_birthday' do
  official_date = Date.new(Date.today.year, 6, 1)

  while official_date.wday != 6
    official_date += 1 # find the first saturday
  end
  official_date += 7 # second saturday

  will_be_was = Date.today > official_date ? 'was' : 'will be'

  ordinality = case official_date.mday % 10
               when 1; 'st'
               when 2; 'nd'
               when 3; 'rd'
               else 'th'
               end
  msg = <<~MSG
    The queen has 2 birthdays. Her actual birthday is the 21st of April. 
    She also has an official birthday and public celebration in June. 
    This year it #{will_be_was} on #{official_date.strftime("%A the %-d#{ordinality} of %B")}. 
    Would you like to know anything else
  MSG

  ask(msg)
end
