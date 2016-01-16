class MainController < ApplicationController
  before_filter :restrict_access, except: :ping
  def ping
    render json: {
      data: [{
        type: "responses",
        attributes: {
          pong: true
        }
        }]
    }
  end
end
