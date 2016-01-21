require 'rails_helper'

describe "lines", type: :request do

  let!(:haiku) { FactoryGirl.create(:haiku) }
  
  describe "haikus new page" do
    it "should render the lines new page" do
      get "/haikus/#{haiku.id}/lines/new"
      expect(response).to have_http_status(200)
      expect(response).to render_template('new')
    end
  end

  describe 'POST /haikus/:id/lines' do
    it "should create a new line" do
      expect {
        post "/haikus/#{haiku.id}/lines", "line" => { "content" => "second line" }
      }.to change(Line, :count).by(1)
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(root_url)
    end
  
    it 'should not create a blank line' do
      expect {
        post "/haikus/#{haiku.id}/lines", "line" => { "content"=> nil }
      }.to change(Line, :count).by(0)
      expect(response).to have_http_status(200)
    end
  end
end
