module Api
  class RollsController < ApplicationController
    def index
      render json: { roll_files: GameConfig.available_roll_files }
    end
  end
end
