require 'rails_helper'

describe "lines", type: :request do

  let!(:haiku) { FactoryGirl.create(:haiku) }
  let!(:user) { FactoryGirl.create(:user) }
  let(:login_params) {{ email: user.email, password: user.password } }

  describe "haikus new page" do
    it "should render the lines new page" do
      get "/haikus/#{haiku.id}/lines/new"
      expect(response).to have_http_status(200)
      expect(response).to render_template('new')
    end
  end

  context 'when logged in' do
    before do
      post '/log_in', login_params
      expect(response).to have_http_status(302)
    end

    describe 'POST /haikus/:id/lines' do
      before(:each) { post '/log_in', login_params }

      it "should create a new line" do
        expect {
          post "/haikus/#{haiku.id}/lines", "line" => { "content" => "second line" }
        }.to change(Line, :count).by(1)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_haiku_line_path(haiku))
      end

      it 'should not create a blank line' do
        expect {
          post "/haikus/#{haiku.id}/lines", "line" => { "content"=> nil }
        }.to change(Line, :count).by(0)
        expect(response).to have_http_status(200)
      end

      it "should add the current user's id to the lines table" do
        expect {
          post "/haikus/#{haiku.id}/lines", "line" => { "content" => "another line" }
        }.to change(Line, :count).by(1)
        expect(Line.last.user).not_to be_nil
      end

      let(:haiku_with_line) { FactoryGirl.create(:haiku_with_line) }
      it "should redirect to haiku edit template when adding third line" do
        expect(haiku_with_line.lines.count).to eq(2)
        post "/haikus/#{haiku_with_line.id}/lines", "line" => { "content" => "third line" }
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(edit_haiku_path(haiku_with_line))
        expect(flash[:notice]).to eq("You can edit your haiku before you complete it.")
      end

      let(:haiku_with_lines) { FactoryGirl.create(:haiku_with_lines) }
      it 'should not add more than 3 lines' do
        expect(haiku_with_lines.lines.count).to eq(3)
        expect(haiku_with_lines).to_not be_lines_count_valid
        expect {
          post "/haikus/#{haiku_with_lines.id}/lines", "line" => { "content" => "fourth line" }
        }.to change(Line, :count).by(0)
        expect(haiku_with_lines.lines.count).to eq(3)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_url)
      end

      it 'should stay on the new line page when a line is not created' do
        post "/haikus/#{haiku.id}/lines", "line" => { "content"=> nil }
        expect(response).to render_template(:new)
      end

      it 'should display an error message' do
        post "/haikus/#{haiku.id}/lines", "line" => { "content"=> nil }
        expect(response.body).to include("Content can&#39;t be blank")
      end
    end
  end

  context 'when logged out' do
    describe 'POST /haikus/:id/lines' do
      it "should create a new line" do
        expect {
          post "/haikus/#{haiku.id}/lines", "line" => { "content" => "second line" }
        }.to change(Line, :count).by(0)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(log_in_url)
      end

      it 'should not create a blank line' do
        expect {
          post "/haikus/#{haiku.id}/lines", "line" => { "content"=> nil }
        }.to change(Line, :count).by(0)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(log_in_url)
      end
    end
  end
end
