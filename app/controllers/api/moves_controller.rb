module Api
  class MovesController < ApplicationController
    def roll
      game = GameService.roll_and_move(params[:game_id] || params[:id])
      move = game.last_move || {}

      render json: {
        previous_position: move[:previous_position],
        new_position: move[:new_position],
        tile_landed_on: move[:tile_landed_on],
        action_required: move[:action_required],
        money_change: move[:money_change],
        updated_game: game.to_h
      }
    rescue KeyError => error
      render json: { error: error.message }, status: :not_found
    rescue ArgumentError => error
      render json: { error: error.message }, status: :unprocessable_entity
    end
  end
end
