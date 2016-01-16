require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'LinesController', type: :request do
  let(:haiku) { FactoryGirl.create(:haiku, {"lines_attributes": {"0": {"content": "haiku line"}}} ) }
  let(:line) { haiku.lines.first }
  let (:api_key) { FactoryGirl.create(:api_key) }
  let(:body) {JSON.parse(response_body)}

  before do
    header "Accept", "application/json"
    header "Content-Type", "application/json"
    header 'AUTHORIZATION', %{Token token="#{api_key.access_token}"}
  end

  get '/lines' do
   let!(:line2) { FactoryGirl.create(:line, haiku_id: haiku.id, content: "Line 2") }
   let!(:line3) { FactoryGirl.create(:line, haiku_id: haiku.id, content: "Line 3") }

    example "GET /lines, with proper authorization headers (success)" do
      client.get "/haikus/#{haiku.id}/lines", nil, headers
      expect(status).to eq(200)
      expect(body["data"].length).to eq(3)
    end
  end

  post '/lines' do
    example "POST lines, with correct params and correct authorization headers (success)" do
      client.post "/haikus/#{haiku.id}/lines", {haiku_id: haiku.id, content: "let's make a haiku"}.to_json, headers
      expect(status).to eq(201)
      expect(Line.last.content).to eq("let's make a haiku")
    end

    example 'error with invalid params' do
      post "/haikus/#{haiku.id}/lines", {}.to_json, headers
      expect(response.status).to eq(400)
    end
  end

  patch '/lines' do
    example "PATCH /lines, with correct params and correct authorization headers (success)" do
      client.patch "/haikus/#{haiku.id}/lines/#{line.id}", {content: "haiku has been updated!"}.to_json, headers
      expect(status).to eq(200)
      line.reload
      expect(body['data']['attributes']['content']).to eq("haiku has been updated!")
    end

    example 'error with invalid params' do
      put "/haikus/#{haiku.id}/lines/#{line.id}", {content: nil}.to_json, headers
      expect(response.status).to eq(400)
    end
  end

  get '/lines/:id' do
    example "GET /lines/:id, with correct authorization headers (success)" do
      client.get "/haikus/#{haiku.id}/lines/#{line.id}", nil, headers
      expect(status).to eq(200)
      expect(body['data']['attributes']['content']).to eq(line.content)
    end
  end

  delete '/lines/:id' do
    let!(:line) { haiku.lines.first }
    example "DELETE /lines/:id, with correct :id and authorization headers (success)" do
      count = Line.count
      client.delete "/haikus/#{haiku.id}/lines/#{line.id}", nil, headers
      expect(status).to eq(204)
      expect(Line.count).to eq(count - 1)
    end
  end
end
