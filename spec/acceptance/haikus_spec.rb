require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'HaikusController', type: :request do
  let(:api_key) { FactoryGirl.create(:api_key) }
  let!(:haikus_list) {FactoryGirl.create_list(:haiku, 5, {"lines_attributes": {"0": {"content": "Haiku line"}}})}
  let(:body) { JSON.parse(response_body) }

  before do
    header "Accept", "application/json"
    header "Content-Type", "application/json"
    header 'AUTHORIZATION', %{Token token="#{api_key.access_token}"}
  end

  get '/haikus' do
    example 'GET haikus, with a valid token (success)' do
      client.get "/haikus", nil, headers
      expect(status).to eq(200)
      expect(body['data'].length).to eq(5)
    end

    example 'GET haikus with first line of each' do
      client.get "/haikus", nil, headers
      line = body['data'][0]['attributes']['first_line']
      expect(line).to eq("Haiku line")
    end
  end

  get '/haikus/:id' do
    let(:haiku) { FactoryGirl.create(:haiku, {"lines_attributes": {"0": {"content": "haiku line"}}} ) }
    example 'GET haikus/:id with a valid token (success)' do
      client.get "haikus/#{haiku.id}", nil, headers
      expect(status).to eq(200)
      expect(body['data']['id'].to_i).to eq(haiku.id)
    end
  end

  post '/haikus' do
    parameter :lines_attributes, '(String, required)'
    parameter '0', '(String, required)', scope: :lines_attributes

    let(:params) {{
      "lines_attributes" => {
        "0" => {
          "content" => "haiku line"
        }
      }
    }}
    example 'POST haikus with a valid token and valid params (success)' do
      client.post '/haikus', params.to_json, headers
      expect(status).to eq(201)
      expect(body["data"][0]["attributes"]["content"]).to eq("haiku line")
    end

    example 'error with invalid params' do
      post '/haikus', {}, headers
      expect(response.status).to eq(400)
    end
  end

  patch '/haikus' do
    let(:haiku) { FactoryGirl.create(:haiku, {"lines_attributes": {"0": {"content": "haiku line"}}} ) }
    example "PATCH haikus with a valid token and valid params (success)" do
      client.patch "/haikus/#{haiku.id}", {content: "updated haiku line"}.to_json, headers
      expect(status).to eq(200)
      haiku.reload
      expect(body['data'].first['attributes']['content']).to eq("updated haiku line")
    end

    example 'error with invalid params' do
      put "/haikus/#{haiku.id}", {content: nil}.to_json, headers
      expect(response.status).to eq(400)
    end
  end

  delete '/haikus/:id' do
    let!(:haiku) { FactoryGirl.create(:haiku, {"lines_attributes": {"0": {"content": "haiku line"}}} ) }
    example "DELETE /haikus with a valid token and valid id (success)" do
      expect{ client.delete "/haikus/#{haiku.id}", nil, headers }.to change{Haiku.count}.by(-1)
    end
  end
end
