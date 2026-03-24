module Api
  class GamesController < ApplicationController
    def create
      game_id = GameService.create_game(player_names_param, config_overrides_param)
      game = GameService.fetch_game(game_id)

      render json: {
        game_id: game.id,
        board: game.board,
        players: game.players,
        current_player_id: current_player_id_for(game)
      }, status: :created
    rescue ArgumentError => error
      render json: { error: error.message }, status: :unprocessable_entity
    end

    private

    def player_names_param
      names = params[:player_names]
      return nil unless names

      Array(names)
    end

    def config_overrides_param
      raw = params.fetch(:config, {}).permit(:go_money, :rent_multiplier, :roll_file).to_h
      overrides = raw.symbolize_keys

      overrides[:go_money] = cast_number(overrides[:go_money]) if overrides.key?(:go_money)
      overrides[:rent_multiplier] = cast_number(overrides[:rent_multiplier]) if overrides.key?(:rent_multiplier)

      overrides
    end

    def cast_number(value)
      return value if value.is_a?(Numeric)

      string_value = value.to_s
      return string_value.to_i if string_value.match?(/\A-?\d+\z/)

      string_value.to_f
    end

    def current_player_id_for(game)
      active_player = game.active_players[game.current_turn]
      active_player&.dig(:id)
    end
  end
end
