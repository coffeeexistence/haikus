require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'UsersController', type: :request do
  let(:api_key) { FactoryGirl.create(:api_key) }
  let!(:user) { FactoryGirl.create(:user, email: 'email@sample.com', password: 'password') }
  let(:body) {JSON.parse(response_body)}

  before do
    header "Accept", "application/json"
    header "Content-Type", "application/json"
    header 'AUTHORIZATION', %{Token token="#{api_key.access_token}"}
  end

  post '/users' do
    example 'POST /users, with correct params and auth headers (success)' do
      client.post '/users', { email: 'newuser@example.com', password: 'password' }.to_json, headers
      expect(body["data"]["attributes"]["email"]).to eq('newuser@example.com')
    end

    example 'error with invalid params' do
      post '/users', {}, headers
      expect(response.status).to eq(400)
    end
  end

  delete '/users' do
    example 'DELETE /users, with correct id and auth headers (success)' do
      expect(User.count).to eq(1)
      delete "/users/#{user.id}", nil, headers
      expect(response.status).to eq(204)
      expect(User.count).to eq(0)
    end
  end
end

