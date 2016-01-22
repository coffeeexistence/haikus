require 'rails_helper'

describe "haikus", type: :request do

  let!(:user) { FactoryGirl.create(:user) }
  let(:params) {{ email: user.email, password: user.password } }

  describe 'writing haiku' do
    it "should render the html" do
      get '/haikus/new'
      expect(response).to have_http_status(200)
      expect(response).to render_template('new')
    end
  end

  describe 'POST /haikus' do

    context 'when logged in' do
      it "should add a new haiku with line content" do
        post '/sessions', params
        expect(response.code).to eq('302')
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=>"An afternoon breeze"}}}
        }.to change(Haiku, :count).by(1)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_url)

        expect(Haiku.last.lines.first.user.email).to eq(user.email)
      end

      it 'should not add a new haiku without line content' do
        post '/sessions', params
        expect(response.code).to eq('302')
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=> nil}}}
        }.to change(Haiku, :count).by(0)
        expect(response).to have_http_status(200)
      end
    end

    context 'when logged out' do
      it 'should not add a new haiku without line content' do
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=>"An afternoon breeze"}}}
        }.to change(Haiku, :count).by(0)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(log_in_url)
      end

      it 'should not add a new haiku without line content' do
        expect {
          post '/haikus', haiku: {"lines_attributes"=>{"0"=>{"content"=> nil}}}
        }.to change(Haiku, :count).by(0)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(log_in_url)
      end
    end
  end
end
