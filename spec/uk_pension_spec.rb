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
          "last_request" => "Because you were born on 1987-06-01 You’ll reach State Pension age on  1 June 2055.",
          "allowed_actions" => "pension_age",
          "birthday"=>'1987-06-01',
        },
        "response" => {
          "outputSpeech"=>{
            "type" => "PlainText",
            "text" => "Because you were born on 1987-06-01 You’ll reach State Pension age on  1 June 2055."
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

    context 'Add year to partial date' do
      let(:json_data) { load_json('add year to existing date') }

      it "will update the date with a year" do
        post '/alexa', json_data

        expect(JSON.parse(last_response.body)).to eq(
          "version" => "1.0",
          "sessionAttributes" => {
            "last_action" => "confirm_details",
            "last_request" => "Because you were born on 1976-09-01 You’ll reach State Pension age on  1 September 2043.",
            "allowed_actions" => "pension_age",
            "birthday"=>'1976-09-01',
          },
          "response" => {
            "outputSpeech"=>{
              "type" => "PlainText",
              "text" => "Because you were born on 1976-09-01 You’ll reach State Pension age on  1 September 2043."
            },
            "shouldEndSession" => false
          }
        )
      end
    end
  end

  context 'pre 1953 birthday' do
    let(:json_data) { load_json('pre 1953 birthday') }

    it "will say it can't handle the request" do
      post '/alexa', json_data

      msg = <<~SSML
        I can't process people born before 6th December 1953, please use
        <speak><phoneme alphabet=\"ipa\" ph=\"ˈɡʌv\">gov</phoneme> dot uk</speak> to
        get your pension date
      SSML
      expect(JSON.parse(last_response.body)).to eq(
        "version" => "1.0",
        "sessionAttributes" => {
          "last_action" => "gender",
          "last_request" => msg,
          "allowed_actions" => "pension_age",
          "birthday"=>'1934',
        },
        "response" => {
          "outputSpeech"=>{
            "type" => "SSML",
            "ssml"=> msg
          },
          "shouldEndSession" => false
        }
      )
    end
  end
end
