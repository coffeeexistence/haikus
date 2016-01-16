require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'ApiKeysController', type: :request do
  let(:api_key) { FactoryGirl.create(:api_key) }
  let(:user) {FactoryGirl.create(:user, email: 'email@sample.com', password: 'password')}

  let(:body) {JSON.parse(response_body)}

  before do
    header "Accept", "application/json"
    header "Content-Type", "application/json"
  end

  post '/api_keys' do
    let!(:params) {{email: user.email, password: user.password}}
    example 'success with valid params' do
      client.post '/api_keys', params, nil
      expect(status).to eq(200)
      expect(body['data']['attributes']['access_token']).to_not be_nil
      expect(body['data']['attributes']['user_id']).to eq(1)
    end

    example 'error with invalid params' do
      post '/api_keys', {}, nil
      expect(response.status).to eq(400)
    end
  end
end

