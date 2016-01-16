require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'MainController', type: :request do
  let(:body) { JSON.parse(response_body) }

  before do
    header "Accept", "application/json"
    header "Content-Type", "application/json"
  end

  get '/ping' do
    example "GET 'pong' without api_token" do
      client.get "ping", nil, headers
      expect(status).to eq(200)
      expect(body["data"][0]["type"]).to eq("responses")
      expect(body["data"][0]["attributes"]["pong"]).to eq(true)
    end
  end
end
