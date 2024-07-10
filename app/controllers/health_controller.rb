class HealthController < ApplicationController
  def index
    render json: { status: 'UP' }, status: :ok
  end
end
