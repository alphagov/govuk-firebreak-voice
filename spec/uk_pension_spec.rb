require 'spec_helper'

RSpec.describe 'uk_pensions' do
  context 'When no DOB or gender is provided in the question' do
    let(:json_data) { load_json('without DOB or gender') }

    it 'Will ask for your date of birth' do
      post '/alexa', json_data

      expect(JSON.parse(last_response.body)).to eq(
        "version" => "1.0",
        "sessionAttributes" => {
          "last_action" => "birthday",
          "last_request" => "Ok what’s your date of birth",
          "allowed_actions" => "getDate getNumber",
          "birthday"=>nil,
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

  context 'When a DOB is provided in the question' do
    let(:json_data) { load_json('with DOB') }

    it 'Will ask for your gender' do
      post '/alexa', json_data

      expect(JSON.parse(last_response.body)).to eq(
        "version" => "1.0",
        "sessionAttributes" => {
          "last_action" => "confirm_details",
          "last_request" => "Because you were born on  You’ll reach State Pension age on  1 June 2055.",
          "allowed_actions" => "pension_age",
          "birthday"=>'1987-06-01',
        },
        "response" => {
          "outputSpeech"=>{
            "type" => "PlainText",
            "text" => "Because you were born on  You’ll reach State Pension age on  1 June 2055."
          },
          "shouldEndSession" => false
        }
      )
    end
  end

  context 'When a partial DOB is provided in the question' do
    let(:json_data) { load_json('with partial DOB - no year') }

    it 'Will ask for your gender' do
      post '/alexa', json_data

      expect(JSON.parse(last_response.body)).to eq(
        "version" => "1.0",
        "sessionAttributes" => {
          "last_action" => "birthday_missing_year",
          "last_request" => "Sorry, I need to know the year. What year were you born",
          "allowed_actions" => "getDate getNumber",
          "birthday"=>'2019-01-01',
        },
        "response" => {
          "outputSpeech"=>{
            "type" => "PlainText",
            "text" => "Sorry, I need to know the year. What year were you born"
          },
          "shouldEndSession" => false
        }
      )
    end
  end
end
