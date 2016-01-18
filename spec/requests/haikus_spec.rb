require 'rails_helper'

RSpec.describe "Haikus", type: :request do

  describe 'writing haiku' do
    it "should render the html" do
      get '/haikus/new'
      expect(response).to have_http_status(200)
      expect(response).to render_template('new')
    end

    it "should add a new haiku with line content" do
      expect {
        post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=>"An afternoon breeze"}}}
      }.to change(Haiku, :count).by(1)
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(root_url)
    end

    it 'should not add a new haiku without line content' do
      expect {
        post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=>""}}}
      }.to_not change(Haiku, :count)
      expect(response).to render_template('new')
    end
  end
end
