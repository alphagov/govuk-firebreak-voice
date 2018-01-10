require 'spec_helper'

RSpec.describe 'uk_pensions' do
  context 'When no DOB or gender is provided in the question' do
    let(:json_data) { load_json('when can I get my pension') }

    it 'Will ask for your date of birth' do
      post '/alexa', json_data

      expect(JSON.parse(last_response.body)).to eq(
        "version" => "1.0",
        "sessionAttributes" => {
          "last_action" => "birthday",
          "last_request" => "Ok what’s your date of birth",
          "allowed_actions" => "getDate getNumber",
          "birthday"=>nil,
          "full_date"=>false
        },
        "response" => {
          "outputSpeech"=>{
            "type" => "PlainText",
            "text" => "Ok what’s your date of birth"
          },
          "shouldEndSession" => false
        }
      )
    end
  end

  context 'When a DOB but no gender is provided in the question' do
    let(:json_data) { load_json('I was born on 1 Jan 1987 when will I get my pension') }

    it 'Will ask for your gender' do
      post '/alexa', json_data

      expect(JSON.parse(last_response.body)).to eq(
        "version" => "1.0",
        "sessionAttributes" => {
          "last_action" => "confirmation",
          "last_request" => "You have said that you were born on 1987-01-01",
          "allowed_actions" => "getConfirmation",
          "birthday"=>'1987-01-01',
          "full_date"=>true
        },
        "response" => {
          "outputSpeech"=>{
            "type" => "PlainText",
            "text" => "You have said that you were born on 1987-01-01"
          },
          "shouldEndSession" => false
        }
      )
    end
  end

end
